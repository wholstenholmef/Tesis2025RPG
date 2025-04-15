extends GridMap

var SFX_node = preload("res://Main/Nodes/SpatialSFX.tscn")

var river_audio_file :String = "res://Assets/SFX/River/calm_river.wav"
var river_audio_stream : AudioStreamWAV

func _ready() -> void:
	generate_river_SFX()

func generate_river_SFX() -> void:
	var geo_grid_map : GridMap = get_node_or_null("%floorGridMap")
	if geo_grid_map == null:
		return
	river_audio_stream = load(river_audio_file)
	for tile in geo_grid_map.get_used_cells_by_item(1):
		var SFX_instance : SpatialSFX = SFX_node.instantiate()
		SFX_instance.one_shot = false
		SFX_instance.max_distance = 4.5
		SFX_instance.stream = river_audio_stream
		SFX_instance.position = geo_grid_map.map_to_local(tile)
		SFX_instance.position.y -= 1.0
		SFX_instance.volume_db = -20.0
		%SFXNode.add_child(SFX_instance)
