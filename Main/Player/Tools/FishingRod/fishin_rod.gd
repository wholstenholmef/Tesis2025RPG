extends Node3D

func _physics_process(delta: float) -> void:
	$handleSprite/lineMarker.global_rotation_degrees.z = 0
	$handleSprite/handleMarker.global_rotation_degrees.x += delta * 10
