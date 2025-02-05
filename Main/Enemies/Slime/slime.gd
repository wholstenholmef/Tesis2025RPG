class_name Slime
extends "res://Main/Enemies/enemy_base.gd"

var colors_array = [
	Color("20d6c7"), #Blue
	Color("d6f264"), #Yellow
	Color("b4202a"), #Red
	Color("bc4a9b"), #Purple
	Color("e9b5a3"), #Brown
]

func _ready() -> void:
	super()
	randomize_color()

func randomize_color() -> void:
	print("color")
	$AnimatedSprite3D.modulate = colors_array.pick_random()
