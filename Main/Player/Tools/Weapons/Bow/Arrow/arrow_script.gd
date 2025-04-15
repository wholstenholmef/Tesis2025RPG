extends RigidBody3D

@export var speed_multiplier : float = 1
var whoosh_VFX_path = "res://Assets/SFX/Weapons/SwordSlashes/"
var thrown := false

func _ready() -> void:
	set_deferred("top_level", true)
	$circleVFX.set_deferred("emitting", false)
	$feathersVFX.set_deferred("emitting", false)
	
	$Node3D/ArrowSprite1.modulate.a = 0
	$Node3D/ArrowSprite2.modulate.a = 0
	var tweener = get_tree().create_tween().set_parallel()
	tweener.tween_property($Node3D/ArrowSprite1, "modulate:a", 1, 0.5)
	tweener.tween_property($Node3D/ArrowSprite2, "modulate:a", 1, 0.5)
	
	var random_vfx :String = whoosh_VFX_path + "swoosh" + str(randi_range(1,3)) + ".wav"
	$AudioStreamPlayer3D.stream = load(random_vfx)

func _physics_process(delta: float) -> void:
	if thrown:
		rotation_degrees.z += 255 * delta
	else:
		self.global_transform = get_parent().global_transform

func shoot() -> void:
	thrown = true
	set_deferred("top_level", true)
	#set_deferred("freeze", false)
	apply_central_impulse(-get_parent().global_transform.basis.z /2 )
	$circleVFX.set_deferred("emitting", true)
	$feathersVFX.set_deferred("emitting", true)
	$AudioStreamPlayer3D.play()
	$flyingSFX.play()
	$Lifetime.start()

func _on_lifetime_timeout() -> void:
	queue_free()
