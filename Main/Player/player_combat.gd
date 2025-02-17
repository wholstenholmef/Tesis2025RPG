extends Node3D

var has_arrow := false

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("attack"):
		$AnimationPlayer.play("bow_draw")
	if Input.is_action_just_released("attack"):
		if $AnimationPlayer.current_animation_position <= 1.0:
			#Retract the bow if it isnt ready
			$AnimationPlayer.play("bow_draw", -1, -3, true)
		else:
			$AnimationPlayer.play("bow_shoot")
