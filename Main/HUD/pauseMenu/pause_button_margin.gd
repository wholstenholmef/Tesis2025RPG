extends MarginContainer

@export_node_path("PauseMenuLayer") var assigned_pause_menu

func _on_gui_input(event: InputEvent) -> void:
	if assigned_pause_menu == null:
		return
	
	if event is InputEventScreenTouch:
		if event.pressed:
			get_node(assigned_pause_menu).toggle_pause()
