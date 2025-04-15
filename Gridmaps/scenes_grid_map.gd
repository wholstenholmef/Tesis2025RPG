extends GridMap

var music_door_scene = preload("res://Main/PuzzlesMinigames/musicDoor/music_door.tscn")
var fishing_puddle_scene 

func _ready() -> void:
	for tile in self.get_used_cells():
		var tile_id = get_cell_item(tile)
		var tile_orientation = get_cell_item_orientation(tile)
		print(tile_orientation)
		match tile_id:
			0: #Puddle
				pass
			1: #Door
				var door_instance : MusicDoorNode = music_door_scene.instantiate()
				%Scenes.call_deferred("add_child", door_instance)
				door_instance.position = map_to_local(tile)
				#This shit makes no sense!!!
				#Refer to this forum for the explanation 
				#https://stackoverflow.com/questions/67443086/gridmap-node-set-cell-item-rotation-of-the-tile-object
				match tile_orientation:
					0:
						door_instance.rotation_degrees.y = 0
					22:
						door_instance.rotation_degrees.y = 90
					10:
						door_instance.rotation_degrees.y = 180
					16:
						door_instance.rotation_degrees.y = -90
		set_cell_item(tile, -1)
