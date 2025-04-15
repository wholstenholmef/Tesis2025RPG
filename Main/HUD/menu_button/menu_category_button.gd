extends MarginContainer

signal selected
var is_selected := false
var category_index : int = 0

@export_enum("Controls", "Music", "Accesibility") var menu_category : String = "Controls"
#var controls_icon = preload("res://Assets/HUD/Icons/gamepad.png")
#var music_icon = preload("res://Assets/HUD/Icons/musicOn.png")
#var star_icon = preload("res://Assets/HUD/Icons/star.png")

var tweener

func _ready() -> void:
	self.pivot_offset = self.size / 2
	#match menu_category:
		#"Controls":
			#$Icon.texture = controls_icon
		#"Music":
			#$Icon.texture = music_icon
		#"Accesibility":
			#$Icon.texture = star_icon

func _on_button_pressed() -> void:
	select()

func set_texture(_texture : Texture) -> void:
	$Icon.texture = _texture

func select() -> void:
	selected.emit()
	
	if tweener:
		tweener.kill()
	tweener = create_tween().set_parallel()
	tweener.tween_property(self, "scale", Vector2.ONE, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tweener.tween_property($Icon, "modulate:a", 1, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	is_selected = true

func deselect() -> void:
	if tweener:
		tweener.kill()
	tweener = create_tween().set_parallel()
	tweener.tween_property(self, "scale", Vector2(0.7, 0.7), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tweener.tween_property($Icon, "modulate:a", 0.7, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	is_selected = false
