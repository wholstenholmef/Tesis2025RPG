extends Node

#var item_nodes_array = []
#@export_node_path("Node3D") var items_main_node
@export_node_path("RichTextLabel") var title_label
@export_node_path("RichTextLabel") var description_label
var cursor_tweener
var tweener
var current_item

var is_cursor_moving := false

func _on_node_screen_swipe(direction) -> void:
	if direction == "right":
		move_items(1.5)
	if direction == "left":
		move_items(-1.5)

func move_items(relative_position) -> void:
	if is_cursor_moving:
		return
	
	is_cursor_moving = true
	if cursor_tweener:
		cursor_tweener.kill()
	cursor_tweener = create_tween()
	cursor_tweener.tween_property(%ItemsMainNode, "position:x", relative_position, 1).as_relative().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	await cursor_tweener.finished
	is_cursor_moving = false

func _on_item_area_entered(area: Area3D) -> void:
	print("colision con " + str(area))
	if !title_label or !description_label:
		return
	
	get_node(title_label).text = "[center][wave]" + str(area.item_name)
	get_node(description_label).text = "[center]" + str(area.item_description)
	
	if tweener:
		tweener.kill()
	tweener = create_tween().set_parallel()
	get_node(title_label).modulate.a = 0
	get_node(description_label).visible_ratio = 0
	tweener.tween_property(get_node(title_label), "position:y", -15, 0.7).as_relative().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tweener.tween_property(get_node(title_label), "modulate:a", 1, 0.7).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tweener.tween_property(get_node(description_label), "visible_ratio", 1, 0.7).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	
func _on_item_area_exited(area: Area3D) -> void:
	if !title_label or !description_label:
		return
	
	if tweener:
		tweener.kill()
	tweener = create_tween().set_parallel()
	tweener.tween_property(get_node(title_label), "position:y", 15, 0.2).as_relative().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tweener.tween_property(get_node(title_label), "modulate:a", 0, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tweener.tween_property(get_node(description_label), "visible_ratio", 0, 0.7).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
