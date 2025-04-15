extends "res://Main/HUD/menu_button/option_buttons/menu_button_option.gd"

@export_enum("Master", "Music", "SFX", "Narrator") var selected_audio_channel : String = "Master"

func load_user_prefs() -> void:
	super()
	match selected_audio_channel:
		"Master":
			set_index(user_prefs_instance.master_volume, false)
		"Music":
			set_index(user_prefs_instance.music_volume, false)
		"SFX":
			set_index(user_prefs_instance.SFX_volume, false)
		"Narrator":
			set_index(user_prefs_instance.SFX_volume, false)

func set_index(_index, narrator := false, save := false) -> void:
	if _index > max_checkboxes:
		uncheck_boxes()
		if allow_zero_index:
			current_index = 0
			if null_text:
				index_label.text = null_text
		else:
			current_index = 1
			check_box(current_index)
	else:
		current_index = _index
		check_box(current_index)
	if show_index_int:
		index_label.text = str(current_index)
	else:
		index_label.text = str(options_array[current_index-1])
	
	change_audio_bus()
	
	if narrator:
		TTS.narrate(index_label.text, true)

func change_audio_bus() -> void:
	var index_to_volume : float = remap(current_index, 0, 5, 0, 1)
	AudioServer.set_bus_volume_db(0, linear_to_db(index_to_volume))
	if user_prefs_instance:
		match selected_audio_channel:
			"Master":
				user_prefs_instance.master_volume = current_index
			"Music":
				user_prefs_instance.music_volume = current_index
			"SFX":
				user_prefs_instance.SFX_volume = current_index
			"Narrator":
				user_prefs_instance.narrator_volume = current_index 
		user_prefs_instance.save()
