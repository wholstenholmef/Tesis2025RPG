class_name SpatialSFX
extends AudioStreamPlayer3D

var one_shot : bool = true

func _on_finished() -> void:
	if one_shot:
		queue_free()
		pass
