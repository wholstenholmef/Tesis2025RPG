extends Node

@export var treshold : int = 50
@export var length : int = 100
var start_pos := Vector2.ZERO
var end_pos := Vector2.ZERO

signal on_screen_tap
signal on_screen_swipe

func _ready() -> void:
	self.call_deferred("reparent", get_node("/root"))

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var viewport_transform = get_viewport().get_canvas_transform()
		if event.pressed:
			#This starts the timer for the single touch input
			$singleTouchTimer.start()
			
			start_pos = viewport_transform.affine_inverse() * event.position
			#print("aqui: " + str(start_pos))
		else:
			#If the single touch timer is still running, it will detect a single touch input
			if !$singleTouchTimer.is_stopped():
				on_screen_tap.emit()
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

func _on_on_screen_swipe(direction) -> void:
	var event = InputEventAction.new()
	var event_release = InputEventAction.new()
	match direction:
		"up":
			event.action = "forward"
		"down":
			event.action = "back"
		"left":
			event.action = "left"
		"right":
			event.action = "right"
	event_release.action = event.action
	event.pressed = true
	event_release.pressed = false
	Input.parse_input_event(event)
	await get_tree().process_frame
	Input.parse_input_event(event_release)
