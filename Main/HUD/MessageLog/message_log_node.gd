extends MarginContainer

#var msg_tweener

func _ready() -> void:
	$"%messageLog".visible_characters = 0

func add_message(msg : String) -> void:
	var previous_total_length = $"%messageLog".get_total_character_count()
	
	$"%messageLog".newline()
	$"%messageLog".append_text(msg)
	
	var new_total_length = $"%messageLog".get_total_character_count()
	#print("tamaño del mensaje:" + str(string_count))
	#var total_log_count = $"%messageLog".text.length()
	#print(total_log_count)
	#if msg_tweener:
		#msg_tweener.kill()
	#msg_tweener = create_tween()
	$"%messageLog".visible_characters = previous_total_length	
	var msg_tweener = get_tree().create_tween()
	msg_tweener.tween_property($"%messageLog", "visible_characters", new_total_length, 1)
	#await msg_tweener.finished
	#print("despues de mensaje: " + str($"%messageLog".visible_characters))
	#$"%messageLog".visible_characters = total_log_count
	#$"%messageLog".visible_characters += string_count

#func _physics_process(delta: float) -> void:
	#print($"%messageLog".visible_ratio)
