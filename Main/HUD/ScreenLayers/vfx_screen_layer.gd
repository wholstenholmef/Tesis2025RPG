extends CanvasLayer

var flash_tweener

func set_droplets_effect(state := true) -> void:
	%dropletsEffect.set_deferred("emitting", state)

func flash_screen(time : float = 1.0) -> void:
	if flash_tweener:
		flash_tweener.kill()
	flash_tweener = create_tween()
	%flashTexture.color.a = 0
	flash_tweener.tween_property(%flashTexture, "color:a", 1, time/2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	flash_tweener.tween_property(%flashTexture, "color:a", 0, time/2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
