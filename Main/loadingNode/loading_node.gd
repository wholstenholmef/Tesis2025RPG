extends Node

var user_pref_instance
@export var main_scene_to_load : PackedScene

@onready var save_file_label = $MarginContainer/VBoxContainer/SaveFileLabel

func _ready() -> void:
	check_user_pref()

func check_user_pref() -> void:
	if userPrefs.save_exists() == false:
		user_pref_instance = userPrefs.create_()
		user_pref_instance.save()
		save_file_label.text = "Archivo de guardado creado " + str(userPrefs.save_exists())
	else:
		save_file_label.text = "Archivo de guardado: " + str(userPrefs.save_exists())

func _on_timer_timeout() -> void:
	get_tree().change_scene_to_packed(main_scene_to_load)
