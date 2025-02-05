extends Camera3D

var target

func _ready() -> void:
	target = %Warrior

func _physics_process(delta: float) -> void:
	position.x = target.position.x
	position.z = target.position.z
