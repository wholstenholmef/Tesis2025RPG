extends "res://Main/HUD/menu_button/menu_button.gd"

@export_enum( 
	"narrator_enabled", \
	"sound_mute"\
) var global_var_reference : String
@export var button_mask_array : Array[customMenuButton]

@onready var label = $contentMargin/HBoxContainer/Label
@onready var checkbox = $contentMargin/HBoxContainer/CheckBox

signal toggled
var toggle_state := false
var color_tweener

func _ready() -> void:
	super()
	load_user_prefs()

func load_user_prefs() -> void:
	super()
	if global_var_reference:
		_on_menu_button_toggled(user_prefs_instance.get(global_var_reference), false)

func _on_menu_button_toggled(toggled_on: bool, narrator = true) -> void:
	#print(narrator)
	print("ao")
	toggle_state = toggled_on
	#$menuButton.button_pressed = toggle_state
	$menuButton.set_pressed_no_signal(toggle_state)
	checkbox.set_pressed_no_signal(toggle_state)
	
	if toggle_state: animate_label_color(Color.BLACK)
	else: animate_label_color(Color.WHITE)
	toggled.emit(toggle_state)
	
	if user_prefs_instance:
		user_prefs_instance.set(global_var_reference, toggle_state)
		user_prefs_instance.save()
	
	if toggle_state:
		if narrator:
			TTS.narrate(button_text + "activado", true)
		show_button_mask()
	else:
		if narrator:
			TTS.narrate(button_text + "desactivado", true)
		hide_button_mask()

#func set_toggle(state = false, narrator = true) -> void:
	#

func hide_button_mask() -> void:
	if button_mask_array.is_empty(): return
	for button in button_mask_array:
		button.hide()

func show_button_mask() -> void:
	if button_mask_array.is_empty(): return
	for button in button_mask_array:
		button.show()

func toggle(toggled_on : bool) -> void:
	if toggled_on: animate_label_color(Color.BLACK)
	else: animate_label_color(Color.WHITE)

func animate_label_color(_color : Color = Color.WHITE) -> void:
	if color_tweener:
		color_tweener.kill()
	color_tweener = create_tween()
	color_tweener.tween_property(label, "theme_override_colors/font_color", _color, 0.4)

func _on_menu_button_focus_entered() -> void:
	#This will narrate the text and state when the button is focused
	#In case the global var refers to the narrator, it will narrate with override
	#Override means it will narrate despite the narrator being disabled
	var is_override := false
	if global_var_reference == "narrator_enabled": is_override = true
	if toggle_state:
		TTS.narrate(button_text + "activado", true, is_override)
	else:
		TTS.narrate(button_text + "desactivado", true, is_override)
	
