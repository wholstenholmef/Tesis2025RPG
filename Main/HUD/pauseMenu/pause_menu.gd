class_name PauseMenuLayer
extends CanvasLayer

@export_node_path("ConfigMenu") var config_menu

@onready var resume_button = $%resumeButton

var is_paused := false

func _ready() -> void:
	SwipeNode.on_screen_swipe.connect(on_swipe)
	SwipeNode.on_screen_tap.connect(on_tap)

func set_pause() -> void:
	pass

func on_swipe(_direction : String) -> void:
	var event = InputEventAction.new()
	if _direction == "up":
		event.action = "ui_focus_prev"
	if _direction == "down":
		event.action = "ui_focus_next"
	event.pressed = true
	Input.parse_input_event(event)
	#match _direction:
		#"up":
			#Input.action_press("ui_up")
			#Input.action_release("ui_up")
		#"down":
			#Input.action_press("ui_down")
			#Input.action_release("ui_down")

func on_tap() -> void:
	var event = InputEventAction.new()
	event.action = "ui_accept"
	event.pressed = true
	Input.parse_input_event(event)
	await get_tree().create_timer(0.1).timeout
	event.pressed = false
	Input.parse_input_event(event)

func toggle_pause() -> void:
	is_paused = !is_paused
	get_tree().set_deferred("paused", is_paused)
	if is_paused:
		open()
		#await get_tree().create_timer(1.5).timeout
		#$VBoxContainer/menuButtonBase/menuButton.call_deferred("grab_focus")
	elif !is_paused:
		close()

func open() -> void:
	self.show()
	$AnimationPlayer.play("open")
	TTS.narrate("Menú de pausa", true)
	$narrationFocusDelayTimer.start()

func close() -> void:
	self.hide()
	$narrationFocusDelayTimer.stop()
	get_viewport().gui_release_focus()
	$AnimationPlayer.play("close")
	TTS.narrate("Juego reanudado", true)

func _on_options_button_pressed() -> void:
	if !config_menu:
		return
	$AnimationPlayer.play("close")
	get_node(config_menu).open()

func _on_resume_button_pressed() -> void:
	toggle_pause()
	get_viewport().gui_release_focus()

func _on_narration_focus_delay_timer_timeout() -> void:
	resume_button.get_node("menuButton").call_deferred("grab_focus")
