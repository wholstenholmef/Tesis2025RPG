extends Node3D

var player_tweener : Tween = null
var camera_tweener : Tween = null
var item_tweener : Tween = null

var current_health : int
var current_experience : int = 0
var exp_to_next_level : int = 1
var current_level := 1
var max_actions : int
var equipped_node

signal movement
signal attacked
signal turn_finished
signal leveling_up
signal item_unequiped
signal item_equiped

@export var stats : stat_sheet
var state
enum MACHINE {
	IN_COMBAT,
	IDLE,
	TURNING,
	MOVING,
	PLAYING_MUSIC,
	ATTACKING
}

var combat_state 
enum C_MACHINE {
	HOLD,
	READY
}

var stone_footsteps_path = "res://Assets/SFX/Footsteps/Stone_footsteps/footstep"
var river_footsteps_path = "res://Assets/SFX/Footsteps/River_footsteps/footstep"
var sword_slashes_path = "res://Assets/SFX/SwordSlashes/swoosh"
var stone_footsteps_SFX = []
var river_footsteps_SFX = []
var sword_slashes_SFX = []
var sfx_suffix = ".wav"


func _ready() -> void:
	state = MACHINE.IDLE
	current_health = stats.max_health
	equip($weaponSprite)
	load_SFX()

func load_SFX() -> void:
	for i in range(1, 15):
		var sfx_load = load(stone_footsteps_path + str(i) + sfx_suffix)
		stone_footsteps_SFX.append(sfx_load)
	for i in range(1, 12):
		var sfx_load = load(river_footsteps_path + str(i) + sfx_suffix)
		river_footsteps_SFX.append(sfx_load)
	for i in range(1, 4):
		var sfx_load = load(sword_slashes_path + str(i) + sfx_suffix)
		sword_slashes_SFX.append(sfx_load)

func _physics_process(delta: float) -> void:
	get_input()
	#print(MACHINE.keys()[state])

func get_input() -> void:
	match state:
		MACHINE.IDLE:
			if Input.is_action_pressed("forward"):
				move(Vector3.FORWARD)
			if Input.is_action_pressed("back"):
				move(Vector3.BACK)
			if Input.is_action_pressed("right"):
				turn(Vector2.RIGHT)
			if Input.is_action_pressed("left"):
				turn(Vector2.LEFT)
			if Input.is_action_just_pressed("attack"):
				interact()
		MACHINE.IN_COMBAT:
			if combat_state == C_MACHINE.READY:
				if Input.is_action_just_pressed("attack"):
					basic_attack()
					attacked.emit(stats.power)

func unequip(node) -> void:
	if item_tweener:
		item_tweener.kill()
	item_tweener = create_tween().set_parallel()
	item_tweener.tween_property(node, "position:y", -1, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD).as_relative()
	item_tweener.tween_property(node, "modulate:a", 0, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	await item_tweener.finished
	node.hide()
	item_unequiped.emit()

func equip(node) -> void:
	if equipped_node:
		unequip(equipped_node)

	var item_y_position : float = 0
	if node == $weaponSprite:
		item_y_position = -0.02
	elif node == $FluteSprite:
		item_y_position = -0.1
	
	node.show()
	node.position.y = -0.3
	node.modulate.a = 0
	
	if item_tweener:
		item_tweener.kill()
	item_tweener = create_tween().set_parallel()
	item_tweener.tween_property(node, "position:y", item_y_position, 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	item_tweener.tween_property(node, "modulate:a", 1, 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	await item_tweener.finished
	item_equiped.emit()

func move(move_dir : Vector3) -> void:
	#Will not move if its not idle
	if state != MACHINE.IDLE:
		return
	state = MACHINE.MOVING
	
	#Points the collision to the front or back, depending of the momevent
	#Will update the raycast, and if its blocked, it wont let the player move
	#Additionally, a little animation plays and a SFX should be played	
	$CollisionRayCast3D.target_position = move_dir * 1.5
	$CollisionRayCast3D.force_raycast_update()
	if $CollisionRayCast3D.is_colliding():
		player_tweener = create_tween()
		player_tweener.tween_property(self, "global_transform:origin", (global_transform.basis * move_dir / 2), 0.2).as_relative()
		player_tweener.tween_property(self, "global_transform:origin", -(global_transform.basis * move_dir / 2), 0.2).as_relative()
		await player_tweener.finished
		state = MACHINE.IDLE
		return
	
	var tile
	$FloorRayCast3D.force_raycast_update()
	if $FloorRayCast3D.is_colliding():
		var geo_grid_map : GridMap = get_node_or_null("../GeometryGridMap")
		if geo_grid_map == null:
			return
		
		var local_position = geo_grid_map.local_to_map(geo_grid_map.to_local(self.global_position))
		tile = geo_grid_map.get_cell_item(local_position)
	
	if tile:
		play_footstep_sfx(tile)
	
	$AnimationPlayer.play("move")
	
	player_tweener = create_tween()
	player_tweener.tween_property(self, "global_transform:origin", global_transform.basis * (move_dir*2), 0.5).as_relative()
	await player_tweener.finished
	
	state = MACHINE.IDLE
	movement.emit()

#func play_footsteps_set(tile) -> void:
	#for i in 2:
		#play_footstep_sfx(tile)
		#await get_tree().create_timer(0.5).timeout
 
func play_footstep_sfx(tile) -> void:
	#Tile IDS!
	#1: Stone floor
	#2: River floor
	#VFX Section
	var library_SFX
	match tile:
		1:
			library_SFX = stone_footsteps_SFX
		2:
			library_SFX = river_footsteps_SFX
	for i in range(1,10):
		var random_sfx = library_SFX.pick_random()
		if random_sfx == $stepSFX.stream:
			continue
		$stepSFX.stream = random_sfx
		break
	$stepSFX.pitch_scale = randf_range(0.8, 1.2)
	$stepSFX.play()

func turn(look_dir : Vector2) -> void:
	if state != MACHINE.IDLE:
		return
	
	state = MACHINE.TURNING
	camera_tweener = create_tween()
	
	for i in range(1,4):
		var random_sfx = stone_footsteps_SFX.pick_random()
		if random_sfx == $stepSFX.stream:
			continue
		$stepSFX.stream = random_sfx
		break
	
	var angle = 0
	match look_dir:
		Vector2.RIGHT:
			angle = -90
		Vector2.LEFT:
			angle = 90
	camera_tweener.tween_property(self, "rotation_degrees:y", angle, 0.3).as_relative()
	await camera_tweener.finished
	state = MACHINE.IDLE

func interact() -> void:
	state = MACHINE.ATTACKING
	$AnimationPlayer.play("attack")
	
	for i in range(1,4):
		var random_sfx = sword_slashes_SFX.pick_random()
		if random_sfx == $attackSFX.stream:
			continue
		$attackSFX.stream = random_sfx
		break
	$attackSFX.pitch_scale = randf_range(0.8, 1.2)
	$attackSFX.play()
	
	await $AnimationPlayer.animation_finished
	state = MACHINE.IDLE

func basic_attack() -> void:
	state = MACHINE.ATTACKING
	$AnimationPlayer.play("attack")
	await $AnimationPlayer.animation_finished
	state = MACHINE.IN_COMBAT
	
	for i in range(1,4):
		var random_sfx = sword_slashes_SFX.pick_random()
		if random_sfx == $attackSFX.stream:
			continue
		$attackSFX.stream = random_sfx
		break
	$attackSFX.pitch_scale = randf_range(0.8, 1.2)
	$attackSFX.play()
	
	max_actions -= 1
	if max_actions <= 0:
		combat_state = C_MACHINE.HOLD
		turn_finished.emit()

func hit(damage) -> void:
	current_health -= damage

func get_enemy_spawn_marker() -> Vector3:
	return Vector3($enemyMarker.global_position.x, 0, $enemyMarker.global_position.z) #Return the marker position always on ground level

func start_turn() -> void:
	state = MACHINE.IN_COMBAT
	combat_state = C_MACHINE.READY
	max_actions = stats.speed

func on_battle_end(exp) -> void:
	state = MACHINE.IDLE
	combat_state = C_MACHINE.HOLD
	current_experience += exp
	if current_experience >= exp_to_next_level:
		level_up()

func level_up() -> void:
	stats.level += 1
	stats.max_health += 2
	stats.crit_chance += 7
	current_health = stats.max_health
	leveling_up.emit()
