class_name ConfigMenu
extends CanvasLayer

@onready var tab_container = %CategoryTabContainer
@onready var category_button_icons = %configurationIconsContainer
@onready var category_label = %configurationNameLabel

var user_pref_instance : userPrefs
var configuration_categories_array = []
var current_category_idx : int = 0

var is_open := false

func _ready() -> void:
	SwipeNode.on_screen_swipe.connect(on_swipe)
	SwipeNode.on_screen_tap.connect(on_tap)
	get_viewport().gui_release_focus()
	
	load_categories()
	create_category_icons()
	user_pref_instance = userPrefs.load_or_create()
	#configuration_categories_array[0].select()

func _physics_process(delta: float) -> void:
	if !is_open:
		return
	
	if Input.is_action_just_pressed("ui_left"):
		configuration_categories_array[current_category_idx].deselect()
		current_category_idx -= 1
		current_category_idx = clamp(current_category_idx, 0, configuration_categories_array.size()-1)
		change_category(current_category_idx)
	if Input.is_action_just_pressed("ui_right"):
		configuration_categories_array[current_category_idx].deselect()
		current_category_idx += 1
		current_category_idx = clamp(current_category_idx, 0, configuration_categories_array.size()-1)
		change_category(current_category_idx)
	#get_viewport().gui_release_focus()
	#configuration_categories_array[current_category_idx].queue_free()

func change_category(_idx := 0) -> void:
	get_viewport().gui_release_focus()
	category_label.text = configuration_categories_array[_idx].category_name
	%Camera2D.position.x = configuration_categories_array[_idx].position.x
	configuration_categories_array[_idx].select()

func open() -> void:
	$AnimationPlayer.play("open")
	await $AnimationPlayer.animation_finished
	is_open = true
	
	TTS.narrate("Menu de configuracion")
	await get_tree().create_timer(1.5).timeout
	change_category(0)

func close() -> void:
	$AnimationPlayer.play("close")
	await $AnimationPlayer.animation_finished
	is_open = false

func load_categories() -> void:
	for margin in %CategoryTabContainer.get_children():
		if margin is ConfigurationCategory:
			configuration_categories_array.append(margin)

func create_category_icons() -> void:
	for category : ConfigurationCategory in configuration_categories_array:
		var texture_instance = TextureRect.new()
		texture_instance.texture = category.category_icon
		texture_instance.stretch_mode = TextureRect.STRETCH_KEEP
		category_button_icons.add_child(texture_instance)

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
