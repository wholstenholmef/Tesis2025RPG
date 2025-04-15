extends Control

var state
enum STATE_MACHINE {
	INTRO,
	WAITING_INPUT,
	ON_MAIN_MENU,
}

#var main_world = preload("res://Main/World/Main.tscn")
var level1 = preload("res://Main/Levels/level_1.tscn")

func _ready() -> void:
	state = STATE_MACHINE.INTRO
	%LogoAnimationPlayer.play("logo_intro")

func _process(delta: float) -> void:
	%debugMenuStateLabel.text = STATE_MACHINE.keys()[state]

func _input(event: InputEvent) -> void:
	if state == STATE_MACHINE.INTRO:
		if Input.is_anything_pressed():
			%LogoAnimationPlayer.seek(1.5)
			$VFXScreenLayer.call_deferred("flash_screen", 0.25)
			state = STATE_MACHINE.ON_MAIN_MENU
			%AnimationPlayer.play("main_menu_show")
	if state == STATE_MACHINE.WAITING_INPUT:
		if Input.is_anything_pressed():
			state = STATE_MACHINE.ON_MAIN_MENU
			%AnimationPlayer.play("main_menu_show")

func intro_trigger() -> void:
	$VFXScreenLayer.call_deferred("flash_screen", 0.25)
	Input.vibrate_handheld(100)

func _on_logo_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "logo_intro":
		state = STATE_MACHINE.WAITING_INPUT
		%AnimationPlayer.play("waiting_input")

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_preferences_button_pressed() -> void:
	$configurationMenuLayer.open()

func _on_start_button_pressed() -> void:
	get_tree().call_deferred("change_scene_to_packed", level1)
