extends Camera3D

var target

func _ready() -> void:
	target = get_tree().get_first_node_in_group("Player")
	#target = %Warrior

func _physics_process(delta: float) -> void:
	global_position.x = target.position.x
	global_position.z = target.position.z
