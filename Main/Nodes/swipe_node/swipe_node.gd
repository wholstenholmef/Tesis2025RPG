extends Node

@export var treshold : int = 50
@export var length : int = 100
var start_pos := Vector2.ZERO
var end_pos := Vector2.ZERO

signal on_screen_swipe

func _ready() -> void:
	reparent_to_main_viewport()

func reparent_to_main_viewport() -> void:
	self.call_deferred("reparent", get_node("/root"))

func _input(event: InputEvent) -> void:
	#if event is InputEventScreenDrag:
		#print(event.position)
	if event is InputEventScreenTouch:
		var viewport_transform = get_viewport().get_canvas_transform()
		if event.pressed:
			start_pos = viewport_transform.affine_inverse() * event.position
			print("aqui: " + str(start_pos))
		else:
			end_pos = viewport_transform.affine_inverse() * event.position
			
			if start_pos.distance_to(end_pos) >= length:
				swipe_released()

func swipe_released() -> void:
	#print("start_pos: " + str(start_pos) + " / end_pos: " + str(end_pos))
	if abs(start_pos.y - end_pos.y) <= treshold:
		if start_pos.x > end_pos.x: on_screen_swipe.emit("left")
		else: on_screen_swipe.emit("right")
	elif abs(start_pos.x - end_pos.x) <= treshold:
		if start_pos.y > end_pos.y: on_screen_swipe.emit("up")
		else: on_screen_swipe.emit("down")
