extends "res://Main/HUD/menu_button/menu_button.gd"

signal option_changed

@export var options_array : Array[String]
@export_enum(\
"narrator_pitch_scale", \
"narrator_rate_speed", \
) var global_var_reference : String

@export var default_index := 3
@export var show_index_int := false
@export var allow_zero_index := false
#This null text refers to the text used when the index is 0
@export var null_text : String

var checkbox_node = preload("res://Main/HUD/menu_button/check_box.tscn")

@onready var index_label = $contentMargin/indexLabel
@onready var checkbox_container = $HBoxContainer/checkboxContainer

var max_checkboxes : int = 0
var current_index : int = 0

func _ready() -> void:
	super()
	await get_tree().create_timer(0.1).timeout
	generate_options()
	#$menuButton.grab_focus()
	max_checkboxes = options_array.size()
	uncheck_boxes()
	load_user_prefs()
	#set_index(default_index)

func generate_options() -> void:
	for element in options_array:
		var checkbox_instance = checkbox_node.instantiate()
		checkbox_container.add_child(checkbox_instance)

func load_user_prefs() -> void:
	user_prefs_instance = userPrefs.load_or_create()
	if global_var_reference:
		var global_index = user_prefs_instance.get(global_var_reference)
		set_index(global_index, false, false)
		#set_index(global_index, false)

func _on_menu_button_pressed() -> void:
	#I repeat the fucking animation here because i dont want to randomize the pitch scale for this button
	if tweener:
		tweener.kill()
	tweener = create_tween()
	tweener.tween_property(self, "scale:y", 0.5, 0.05).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tweener.tween_property(self, "scale:y", 1, 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

	#Sum the current index on button pressed
	#Then we compare these to the max. checkboxes
	#We reset and uncheck every button if it exceeds the maximum
	current_index += 1
	set_index(current_index, true, true)

	#Incremental pitch scale based on the current index
	if current_index != 0:
		$clickSFX.pitch_scale = (current_index / 2) + 0.5
	else:
		$clickSFX.pitch_scale = 0.4
	$clickSFX.play()
	
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
	
	if save:
		if user_prefs_instance:
			user_prefs_instance.set(global_var_reference, current_index)
			print("saved with: " + str(current_index))
			user_prefs_instance.save()
		
	if narrator:
		TTS.narrate(index_label.text, true)

func uncheck_boxes() -> void:
	for node in checkbox_container.get_children():
		if !(node is CheckBox):
			continue
		node.button_pressed = false

func check_box(index) -> void:
	if index == 0:
		return
	uncheck_boxes()
	checkbox_container.get_child(index-1).button_pressed = true
	#get_node("HBoxContainer/CheckBox" + str(index)).button_pressed = true

func _on_menu_button_focus_entered()-> void:
	super()
	TTS.narrate(options_array[current_index - 1])
