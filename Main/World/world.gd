extends Node

@export var minutes_per_step : int = 15
@export_range(0, 100) var random_encounter_ratio : int
var current_day : int = 1
var current_hour : int = 6
var current_minutes : int = 0

var battle_exp : int = 0

var enemy_array = [
	"res://Main/Enemies/Slime/slime.tscn"
]

var combat_state
enum MACHINE {
	HOLD,
	PLAYER_TURN,
	ENEMY_TURN,
	END
}

@onready var warrior = %Warrior
@export_node_path("RichTextLabel") var timeLabel
@export_node_path("RichTextLabel") var dayLabel

var SFX_node = preload("res://Main/Nodes/SpatialSFX.tscn")

var river_audio_file :String = "res://Assets/SFX/River/calm_river.wav"
var river_audio_stream : AudioStreamWAV

var door_node = preload("res://Main/musicDoor/door.tscn")

func _ready() -> void:
	#update_HUD()
	generate_river_SFX()
	generate_gridmap_scenes()

func generate_river_SFX() -> void:
	var geo_grid_map : GridMap = get_node_or_null("%GeometryGridMap")
	if geo_grid_map == null:
		return
	river_audio_stream = load(river_audio_file)
	for tile in geo_grid_map.get_used_cells_by_item(2):
		var SFX_instance = SFX_node.instantiate()
		SFX_instance.stream = river_audio_stream
		SFX_instance.position = geo_grid_map.map_to_local(tile)
		%VFXNodes.add_child(SFX_instance)
		#geo_grid_map.set_cell_item(tile, -1)
	#var local_position = geo_grid_map.local_to_map(geo_grid_map.to_local(self.global_position))
	#tile = geo_grid_map.get_cell_item(local_position)

func generate_gridmap_scenes() -> void:
	var scenes_grid_map : GridMap = get_node_or_null("%ScenesGridMap")
	if scenes_grid_map == null:
		return
	
	#Door creation
	for tile in scenes_grid_map.get_used_cells_by_item(0):
		var door_instance = door_node.instantiate()
		$"%SubViewport".call_deferred("add_child", door_instance)
		door_instance.position = scenes_grid_map.map_to_local(tile)
		scenes_grid_map.set_cell_item(tile, -1)

func _on_warrior_movement() -> void:
	change_hour()
	#random_enemy_encounter()

func set_hour(hour, minutes) -> void:
	current_hour = hour
	current_minutes = minutes
	%hourLabel.text = "[center] " + str(current_hour).pad_zeros(2) + ":" + str(current_minutes).pad_zeros(2)

func change_hour() -> void:
	current_minutes += minutes_per_step
	if current_minutes >= 60:
		current_minutes = 0
		current_hour += 1
	if current_hour >= 24:
		current_hour = 0
		current_minutes = 0
		change_day()
	
	if timeLabel:
		get_node(timeLabel).text = "[center] " + str(current_hour).pad_zeros(2) + ":" + str(current_minutes).pad_zeros(2)

func change_day() -> void:
	current_day += 1
	get_node(dayLabel).text = "[center] " + "DAY " + str(current_day)

func random_enemy_encounter() -> void:
	var rand_int = randi_range(0, 100)
	if rand_int < random_encounter_ratio:
		start_enemy_combat() 

func start_enemy_combat() -> void:
	var rand_enemy_node = load(enemy_array.pick_random())
	var enemy_instance = rand_enemy_node.instantiate()
	%EnemiesNode.add_child(enemy_instance)
	enemy_instance.attacked.connect(on_enemy_attacked)
	enemy_instance.death.connect(on_enemy_death)
	
	enemy_instance.position = warrior.get_enemy_spawn_marker()
	
	$messageLogNode.add_message("An enemy " + "[color=red]" + str(enemy_instance.stats.name) + "[/color]" + " appears!")
	
	warrior_turn()

func warrior_turn() -> void:
	combat_state = MACHINE.PLAYER_TURN
	$"%Warrior".start_turn()

func _on_warrior_attacked(damage) -> void:
	if combat_state != MACHINE.PLAYER_TURN:
		return
	$messageLogNode.add_message("The warrior swings his blade for " + "[color=yellow]" + str(damage) + " damage" + "[/color]")
	for enemy in $"%EnemiesNode".get_children():
		enemy.hit(damage)
	#await get_tree().create_timer(1).timeout

func _on_warrior_turn_finished() -> void:
	await get_tree().create_timer(0.5).timeout
	if combat_state == MACHINE.PLAYER_TURN:
		combat_state = MACHINE.ENEMY_TURN
		enemy_turn()

func enemy_turn() -> void:
	for enemy in $"%EnemiesNode".get_children():
		enemy.attack()
		await enemy.attacked
		await get_tree().create_timer(0.5).timeout
	if %"EnemiesNode".get_child_count() <= 0:
		battle_end()
		return
	warrior_turn()

func on_enemy_attacked(enemy_name, damage) -> void:
	warrior.hit(damage)
	#update_HUD()
	
	var log_message = "The enemy " + "[color=red]{enemy_name}[/color]" + " attacks for " + "[color=orange]{damage_count} damage[/color]"
	log_message = log_message.format({"enemy_name": str(enemy_name), "damage_count": str(damage)})
	$messageLogNode.add_message(log_message)

func on_enemy_death(enemy_name, exp_points) -> void:
	$messageLogNode.add_message("The enemy " + str(enemy_name) + " was defeated!")
	battle_exp += exp_points
	#await get_tree().create_timer(0.5).timeout
	#if $"%EnemiesNode".get_child_count() <= 0:
		#battle_end()

func battle_end() -> void:
	combat_state = MACHINE.END
	$messageLogNode.add_message("[wave] The warrior has won the battle! [/wave] They gain " + "[color=blue]" +  str(battle_exp) +" experience points" + "[/color]")
	warrior.on_battle_end(battle_exp)
	battle_exp = 0

func _on_warrior_leveling_up() -> void:
	#update_HUD()
	pass

#func update_HUD() -> void:
	#%lifeValueLabel.text = str(warrior.current_health)
	#%powerValueLabel.text = str(warrior.stats.power)
	#%speedValueLabel.text = str(warrior.stats.speed)
	#%critChanceLabel.text = str(warrior.stats.level) + "%"
	#%levelLabel.text = "LVL." + str(warrior.current_level).pad_zeros(2)
