class_name Enemy
extends Node

@export var stats : stat_sheet
#@export var 
signal attacked

var current_health : int
var attack_power = 0

signal death

func _ready() -> void:
	if stats != null:
		current_health = stats.max_health
		attack_power = stats.power

func hit(damage) -> void:
	current_health -= damage
	if current_health <= 0:
		death.emit(stats.name, stats.level)
		#await get_tree().create_timer(0.1).timeout
		self.queue_free()
	$AnimationPlayer.play("hit")

func attack() -> void:
	$AnimatedSprite3D.play("attack")
	await $AnimatedSprite3D.animation_finished
	attacked.emit(stats.name, attack_power)
