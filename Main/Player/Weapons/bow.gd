extends Node3D

var arrow_node = preload("res://Main/Player/Weapons/arrow.tscn")
var current_arrow : ArrowProjectile
var has_arrow := false

var draw_SFX_path := "res://Assets/SFX/Weapons/Bow/"
var draw_SFX_name := "bow_tense_"
var SFX_suffix := ".wav"

var state
enum MACHINE {
	IDLE, 
	DRAW,
	SHOOT, 
	RELOAD
}

var tweener

func _ready() -> void:
	#state = MACHINE.IDLE
	reload()
	center_crosshair()

func _physics_process(delta: float) -> void:
	$CanvasLayer/debugLabel.text = "state = " + str(MACHINE.keys()[state])
	
	match state:
		MACHINE.IDLE:
			%crosshairSprite.rotation += 1 * delta
			if Input.is_action_just_pressed("attack"):
				$AnimationPlayer.play("bow_draw")
				play_draw_SFX()
				
				#Crosshair animation
				#It will rotate to the left and shrink down
				if tweener:
					tweener.kill()
				tweener = create_tween().set_parallel()
				tweener.tween_property(%crosshairSprite, "rotation_degrees", -360, 1).as_relative().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
				tweener.tween_property(%crosshairSprite, "scale", Vector2(0.2, 0.2), 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
				
				state = MACHINE.DRAW
		MACHINE.DRAW:
			if Input.is_action_just_released("attack"):
				var draw_lenght : float = $AnimationPlayer.current_animation_position
				print(draw_lenght)
				if draw_lenght <= 0.7:
					$drawSFX.stop()
					$AnimationPlayer.play("bow_draw", -1, -3, true)
					
					if tweener:
						tweener.kill()
					tweener = create_tween().set_parallel()
					tweener.tween_property(%crosshairSprite, "rotation_degrees", 30, 0.2).as_relative().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
					tweener.tween_property(%crosshairSprite, "scale", Vector2.ONE, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
					
					state = MACHINE.IDLE
				else:
					shoot()
		MACHINE.SHOOT:
			pass
		MACHINE.RELOAD:
			%crosshairSprite.rotation += 1 * delta

func shoot() -> void:
	$AnimationPlayer.play("bow_shoot")
	if tweener:
		tweener.kill()
	tweener = create_tween().set_parallel()
	tweener.tween_property(%crosshairSprite, "modulate:a", 0, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tweener.tween_property(%crosshairSprite, "scale", Vector2.ONE * 2, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	
	$releaseSFX.play()
	$releaseSFX.pitch_scale = randf_range(0.9, 1.2)
	
	$sparksVFX.set_deferred("emitting", true)
	
	current_arrow.shoot()
	current_arrow.linear_velocity = -$Path3D/PathFollow3D/arrowMarker.global_transform.basis.z * current_arrow.speed_multiplier
	
func play_draw_SFX() -> void:
	var random_SFX : String = draw_SFX_path + draw_SFX_name + str(randi_range(1,3)) + SFX_suffix  
	$drawSFX.stream = load(random_SFX)
	$drawSFX.play()

func center_crosshair() -> void:
	var viewport_size : Vector2i = get_viewport().size
	var center_position : Vector2i = viewport_size / 2
	var sprite_offset = Vector2i(16,16)
	$SubViewportContainer.position = center_position - sprite_offset

func reload() -> void:
	$AnimationPlayer.play("bow_reload")
	if tweener:
		tweener.kill()
	tweener = create_tween().set_parallel()
	tweener.tween_property(%crosshairSprite, "modulate:a", 1, 1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tweener.tween_property(%crosshairSprite, "scale", Vector2.ONE, 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	
	$Path3D/PathFollow3D/arrowMarker/reloadSFX.pitch_scale = randf_range(0.8, 1.3)
	$Path3D/PathFollow3D/arrowMarker/reloadSFX.play()
	
	var arrow_instance : ArrowProjectile = arrow_node.instantiate()
	$Path3D/PathFollow3D/arrowMarker.call_deferred("add_child", arrow_instance)
	current_arrow = arrow_instance
	
	state = MACHINE.RELOAD

func _on_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"bow_shoot":
			reload()
		"bow_reload":
			state = MACHINE.IDLE
