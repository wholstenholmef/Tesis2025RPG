class_name Player
extends Node3D

signal movement
signal attacked
signal turn_finished
signal leveling_up
signal item_unequiped
signal item_equiped

var player_tweener : Tween = null
var camera_tweener : Tween = null
var item_tweener : Tween = null

@export var stats : stat_sheet
@export var auto_inventory : bool = true
@export_node_path("ToolBase") var autoequip_tool 
@export var move_speed_in_seconds : float = 0.6

var current_health : int
var current_experience : int = 0
var exp_to_next_level : int = 1
var current_level := 1

var inventory_array
var inventory_index : int = 0
var equipped_tool : ToolBase

var is_on_water := false
var is_wet := false

var state
enum MACHINE {
	IDLE,
	TURNING,
	MOVING,
	CHANGING_EQUIPMENT,
	USING_TOOL,
	INTERACTING,
}

var tool_state 
enum TOOL_MACHINE {
	NONE,
	GUITAR,
	FISHING,
	BOW,
}

var stone_footsteps_path = "res://Assets/SFX/Footsteps/Stone_footsteps/footstep"
var river_footsteps_path = "res://Assets/SFX/Footsteps/River_footsteps/footstep"
var dripping_water_path = "res://Assets/SFX/WetDripping/dripping"
var grass_footsteps_path = "res://Assets/SFX/Footsteps/Grass_footsteps/footstep"
var stone_footsteps_SFX = []
var river_footsteps_SFX = []
var dripping_water_SFX = []
var grass_footsteps_SFX = []
var sfx_suffix = ".wav"

var spatial_sfx_node = preload("res://Main/Nodes/SpatialSFX.tscn")

func _ready() -> void:
	state = MACHINE.IDLE
	current_health = stats.max_health
	load_SFX()
	
	if autoequip_tool != null:
		equip_tool(get_node(autoequip_tool))
	SwipeNode.on_screen_swipe.connect(_on_screen_swipe)

func load_SFX() -> void:
	#The +1 is to get the last number in the range
	#Stone footsteps
	for i in range(1, 15+1):
		var sfx_load = load(stone_footsteps_path + str(i) + sfx_suffix)
		stone_footsteps_SFX.append(sfx_load)
	#River footsteps
	for i in range(1, 12+1):
		var sfx_load = load(river_footsteps_path + str(i) + sfx_suffix)
		river_footsteps_SFX.append(sfx_load)
	#Dripping water 
	for i in range(2,3+1):
		var sfx_load = load(dripping_water_path + str(i) + sfx_suffix)
		dripping_water_SFX.append(sfx_load)
	#Grass footsteps
	for i in range(1, 11+1):
		var sfx_load = load(grass_footsteps_path + str(i) + sfx_suffix)
		grass_footsteps_SFX.append(sfx_load)
		
func _physics_process(delta: float) -> void:
	get_input()
	
	#if is_wet:
		#%dropletsEffect.set_deferred("emitting", true)
	#else:
		#%dropletsEffect.set_deferred("emitting", false)
	#print(MACHINE.keys()[state])

func get_input() -> void:
	if Input.is_action_just_pressed("inventory_next"):
		inventory_next()
	handle_interact()
	
	match state:
		MACHINE.IDLE:
			match tool_state:
				#Playing guitar
				TOOL_MACHINE.GUITAR:
					handle_turning()
				#Fishing minigame
				TOOL_MACHINE.FISHING:
					pass
				_:
					handle_movement()
					handle_turning()
		MACHINE.USING_TOOL:
			pass

func inventory_next() -> void:
	if state != MACHINE.IDLE:
		return
	
	if equipped_tool:
		if equipped_tool.is_busy():
			return
	
	inventory_array = %InventoryNode.get_children()
	if inventory_array.is_empty():
		return
	
	#print(inventory_index)
	inventory_index += 1
	if inventory_index >= inventory_array.size():
		unequip_tool()
		inventory_index = -1
		return
	#print(inventory_index)
	equip_tool(inventory_array[inventory_index])
	#inventory_array[inventory_index].equip()

func handle_movement() -> void:
	if Input.is_action_pressed("forward"):
		move(Vector3.FORWARD)
	if Input.is_action_pressed("back"):
		move(Vector3.BACK)

func handle_turning() -> void:
	if Input.is_action_pressed("right"):
		turn(Vector2.RIGHT)
	if Input.is_action_pressed("left"):
		turn(Vector2.LEFT)

func handle_interact() -> void:
	if Input.is_action_just_pressed("interact"):
		var collider = %interactRayCast3D.get_collider()
		if collider == null:
			return
		if collider.is_in_group("interactable"):
			print("interactuo")

func _on_screen_swipe(direction : String) -> void:
	var event = InputEventAction.new()
	var event_release = InputEventAction.new()
	match direction:
		"up":
			event.action = "forward"
		"down":
			event.action = "back"
		"left":
			event.action = "left"
		"right":
			event.action = "right"
	event_release.action = event.action
	event.pressed = true
	Input.parse_input_event(event)
	await get_tree().process_frame
	event_release.pressed = false
	Input.parse_input_event(event_release)

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
		player_tweener.tween_property(self, "global_transform:origin", (global_transform.basis * move_dir / 2), move_speed_in_seconds/2).as_relative()
		player_tweener.tween_property(self, "global_transform:origin", -(global_transform.basis * move_dir / 2), move_speed_in_seconds/2).as_relative()
		await player_tweener.finished
		state = MACHINE.IDLE
		return
	
	#if tile:
		#play_footstep_sfx(tile)
	step_on_tile()
	$AnimationPlayer.play("move")
	step_on_tile(0.3)
	
	player_tweener = create_tween()
	player_tweener.tween_property(self, "global_transform:origin", global_transform.basis * (move_dir*2), move_speed_in_seconds).as_relative()
	await player_tweener.finished
	
	state = MACHINE.IDLE
	movement.emit()

func turn(look_dir : Vector2) -> void:
	if state == MACHINE.MOVING:
		return
	if state == MACHINE.TURNING:
		return
	
	state = MACHINE.TURNING
	camera_tweener = create_tween()
	var angle = 0
	match look_dir:
		Vector2.RIGHT:
			angle = -90
		Vector2.LEFT:
			angle = 90
	camera_tweener.tween_property(self, "rotation_degrees:y", angle, 0.3).as_relative().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	await camera_tweener.finished
	state = MACHINE.IDLE

#func play_footsteps_set(tile) -> void:
	#for i in 2:
		#play_footstep_sfx(tile)
		#await get_tree().create_timer(0.5).timeout

func get_tile_id() -> int:
	var tile
	$FloorRayCast3D.force_raycast_update()
	if $FloorRayCast3D.is_colliding():
		var geo_grid_map : GridMap = get_node_or_null("../floorGridMap")
		if geo_grid_map == null:
			print(-1)
			return -1
		else:
			var local_position = geo_grid_map.local_to_map(geo_grid_map.to_local(self.global_position))
			tile = geo_grid_map.get_cell_item(local_position)
			return tile
	else:
		return -1

func step_on_tile(delay : float = 0) -> void:
	if delay != 0:
		await get_tree().create_timer(delay).timeout
	var tile = get_tile_id()
	
	#Checks if it was on water previously
	#After checking the tile id, it determines if its on water or not
	var was_on_water = is_on_water
	match tile:
		1:
			is_on_water = true
			is_wet = true
			%VFXScreenLayer.set_droplets_effect(true)
		_:
			is_on_water = false
			%VFXScreenLayer.set_droplets_effect(false)
	play_footstep_sfx(tile)
	
	if was_on_water and !is_on_water:
		$drippingWaterSFX.stream = dripping_water_SFX.pick_random()
		$drippingWaterSFX.volume_db = -40
		$drippingWaterSFX.play()
		await $drippingWaterSFX.finished
		is_wet = false
 
func play_footstep_sfx(tile_id : int) -> void:
	#Tile IDS!
	#1: Stone floor
	#2: River floor
	#3: Grass floor
	#4: Dock
	#VFX Section
	var library_SFX
	var custom_distance : float = 1.0
	match tile_id:
		0:
			library_SFX = stone_footsteps_SFX
		1:
			#For some reason the river footsteps sound extra quiet despite being normalized
			library_SFX = river_footsteps_SFX
			custom_distance = 1.5
		2:
			library_SFX = grass_footsteps_SFX
		_:
			return
	var spatial_sfx_instance : SpatialSFX = spatial_sfx_node.instantiate()
	get_parent().add_child(spatial_sfx_instance)
	spatial_sfx_instance.position = self.global_position
	spatial_sfx_instance.position.y -= 0.5
	spatial_sfx_instance.max_distance = custom_distance
	
	var random_sfx = library_SFX.pick_random()
	spatial_sfx_instance.stream = random_sfx
	spatial_sfx_instance.pitch_scale = randf_range(0.8, 1.2)
	spatial_sfx_instance.play()

#func interact() -> void:
	#state = MACHINE.ATTACKING
	#$AnimationPlayer.play("attack")
	#
	#for i in range(1,4):
		#var random_sfx = sword_slashes_SFX.pick_random()
		#if random_sfx == $attackSFX.stream:
			#continue
		#$attackSFX.stream = random_sfx
		#break
	#$attackSFX.pitch_scale = randf_range(0.8, 1.2)
	#$attackSFX.play()
	#
	#await $AnimationPlayer.animation_finished
	#state = MACHINE.IDLE

#func basic_attack() -> void:
	#state = MACHINE.ATTACKING
	#$AnimationPlayer.play("attack")
	#await $AnimationPlayer.animation_finished
	#state = MACHINE.IN_COMBAT
	#for i in range(1,4):
		#var random_sfx = sword_slashes_SFX.pick_random()
		#if random_sfx == $attackSFX.stream:
			#continue
		#$attackSFX.stream = random_sfx
		#break
	#$attackSFX.pitch_scale = randf_range(0.8, 1.2)
	#$attackSFX.play()

func hit(damage) -> void:
	current_health -= damage

func get_enemy_spawn_marker() -> Vector3:
	return Vector3($enemyMarker.global_position.x, 0, $enemyMarker.global_position.z) #Return the marker position always on ground level

func level_up() -> void:
	stats.level += 1
	stats.max_health += 2
	stats.crit_chance += 7
	current_health = stats.max_health
	leveling_up.emit()

#func unequip_tool(tool_node : ToolBase) -> void:
	#tool_node.unequip()

func unequip_tool() -> void:
	if equipped_tool:
		equipped_tool.unequip()
	await equipped_tool.unequipped_animation_finished
	equipped_tool = null
	tool_state = TOOL_MACHINE.NONE

func equip_tool(tool_node : ToolBase) -> void:
	state = MACHINE.CHANGING_EQUIPMENT
	if equipped_tool:
		equipped_tool.unequip()
		await equipped_tool.unequipped_animation_finished
	tool_node.equip()
	equipped_tool = tool_node
	if equipped_tool is MagicGuitar:
		tool_state = TOOL_MACHINE.GUITAR
	if equipped_tool is WindBow:
		tool_state = TOOL_MACHINE.BOW
	await equipped_tool.equipped_animation_finished
	state = MACHINE.IDLE
	#var item_y_position : float = 0
	#if node == $weaponSprite:
		#item_y_position = -0.02
	#elif node == $FluteSprite:
		#item_y_position = -0.1
	
	#node.show()
	#node.position.y = -0.3
	#node.modulate.a = 0
	
	#if item_tweener:
		#item_tweener.kill()
	#item_tweener = create_tween().set_parallel()
	#item_tweener.tween_property(node, "position:y", item_y_position, 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	#item_tweener.tween_property(node, "modulate:a", 1, 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	#await item_tweener.finished
	#item_equiped.emit()
