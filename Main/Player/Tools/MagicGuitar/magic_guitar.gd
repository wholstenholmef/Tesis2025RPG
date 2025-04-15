class_name MagicGuitar
extends ToolBase

var spatial_sfx = preload("res://Main/Nodes/SpatialSFX.tscn")
var strum_down_sfx = preload("res://Assets/SFX/guitarStrums/strum_down.wav")
var strum_up_sfx = preload("res://Assets/SFX/guitarStrums/strum_up.wav")

var strum_arrow_node = preload("res://Main/Player/Tools/MagicGuitar/strumArrow/strum_arrow.tscn")

var default_rotation_z : int = -105

var tweener

func _ready() -> void:
	super()
	#SwipeNode.on_screen_swipe.connect(play_strum)

func _process(delta: float) -> void:
	if !active:
		return
	
	if Input.is_action_just_pressed("forward"):
		play_strum("up")
	if Input.is_action_just_pressed("back"):
		play_strum("down")

func play_strum(direction : String) -> void:
	if in_cooldown:
		return
	in_cooldown = true
	%cooldownTimer.start()
	
	if direction not in ["up", "down"]:
		return
	var sfx_instance : AudioStreamPlayer3D = spatial_sfx.instantiate()
	get_node("SFX").add_child(sfx_instance)
	#sfx_instance.pitch_scale = randf_range(0.95, 1.05)
	if direction == "up":
		sfx_instance.stream = strum_up_sfx
		tween_guitar(15)
		display_strum_arrow()
	elif direction == "down":
		sfx_instance.stream = strum_down_sfx
		tween_guitar(-15)
		display_strum_arrow(true)
	sfx_instance.play()
	send_note_signal()

func send_note_signal() -> void:
	%musicRaycast.force_raycast_update()
	if %musicRaycast.get_collider() is MusicDoorNode:
		print("yayy")

func display_strum_arrow(flip_v = false) -> void:
	#If there are four or more arrows already, it will erase the first one
	if %strumArrowContainer.get_child_count() >= 4:
		%strumArrowContainer.get_children()[0].queue_free()
	
	var arrow_instance : TextureRect = strum_arrow_node.instantiate()
	%strumArrowContainer.add_child(arrow_instance)
	
	arrow_instance.flip_v = flip_v
	arrow_instance.modulate.a = 0
	var arrow_position_offset = 0
	if flip_v: arrow_position_offset = -16
	else:      arrow_position_offset = 16
	
	var arrow_tweener = create_tween()
	arrow_tweener.tween_property(arrow_instance, "position:y", arrow_position_offset, 0.01)
	arrow_tweener.chain().tween_property(arrow_instance, "position:y", 0, 0.7).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	arrow_tweener.parallel().tween_property(arrow_instance, "modulate:a", 1, 0.7).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

func unequip() -> void:
	super()
	fade_strum_arrows()

func fade_strum_arrows() -> void:
	for arrow in %strumArrowContainer.get_children():
		var tweener = create_tween().set_parallel()
		tweener.tween_property(arrow, "position:y", 32, 0.15)
		tweener.tween_property(arrow, "modulate:a", 0, 0.15)
		await tweener.finished
		arrow.queue_free()
	#for arrow in %strumArrowContainer.get_children():
		#arrow.queue_free()

func tween_guitar(increment_degree = 15) -> void:
	if tweener:
		tweener.kill()
	tweener = create_tween()
	tweener.tween_property($Sprite3D, "rotation_degrees:z", default_rotation_z + increment_degree, 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tweener.tween_property($Sprite3D, "rotation_degrees:z", default_rotation_z, 0.25).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
