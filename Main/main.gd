extends Node

var log_displayed = false

func set_log_display(state = true) -> void:
	if state:
		log_displayed = true
		$AnimationPlayer.play("show_chat_log")
	else:
		log_displayed = false
		$AnimationPlayer.play("hide_chat_log")

func _on_log_button_margin_gui_input(event: InputEvent) -> void:
	if $AnimationPlayer.is_playing():
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			set_log_display(!log_displayed)

func _on_inventory_button_margin_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			var input_event = InputEventAction.new()
			var input_event_release = InputEventAction.new()
			input_event.action = "inventory_next"
			input_event_release.action = "inventory_next"
			input_event.pressed = true
			input_event_release.pressed = false
			Input.parse_input_event(input_event)
			await get_tree().create_timer(0.1).timeout
			Input.parse_input_event(input_event_release)
			#await get_tree().process_frame
			#input_event.pressed = false
			#Input.parse_input_event(input_event)
