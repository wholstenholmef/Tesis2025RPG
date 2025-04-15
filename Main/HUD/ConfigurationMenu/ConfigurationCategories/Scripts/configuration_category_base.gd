class_name ConfigurationCategory
extends MarginContainer

@export var category_name : String = "Configuración"
@export var category_icon : Texture = preload("res://Assets/HUD/Icons/gear.png")
var narration_start_delay := 1.5

@export_node_path("MarginContainer") var first_button

@onready var button_container = %buttonContainer

func _ready() -> void:
	get_viewport().gui_release_focus()
	button_container.get_children()[0].get_node("menuButton").grab_focus()

func select() -> void:
	get_viewport().gui_release_focus()
	TTS.narrate("Configuración de " + str(category_name), true)
	$narrationTimer.start()
	#await get_tree().create_timer(1.5).timeout
	#button_container.get_children()[0].get_node("menuButton").grab_focus()

func deselect() -> void:
	$narrationTimer.stop()

func _on_narration_timer_timeout() -> void:
	button_container.get_children()[0].get_node("menuButton").grab_focus()
