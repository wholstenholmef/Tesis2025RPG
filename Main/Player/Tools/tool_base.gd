class_name ToolBase
extends Node3D

signal equipped_animation_finished
signal unequipped_animation_finished

var in_cooldown : bool = false
var active : bool = false

func _ready() -> void:
	%debugCamera.queue_free()
	await get_tree().process_frame
	self.position = %equippedMarkerPosition.position

func equip() -> void:
	$AnimationPlayer.play("retrieve")
	await $AnimationPlayer.animation_finished
	equipped_animation_finished.emit()
	active = true

func unequip() -> void:
	active = false
	$AnimationPlayer.play("save")
	await $AnimationPlayer.animation_finished
	unequipped_animation_finished.emit()

func _on_cooldown_timer_timeout() -> void:
	in_cooldown = false

func is_busy() -> bool:
	return false
