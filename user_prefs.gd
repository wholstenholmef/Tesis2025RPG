class_name userPrefs
extends Resource

#The options range from int 1 to 5, indicating the levels themselves, 3 being the default
##Narrator preferences
@export var narrator_enabled := false
@export var narrator_volume : float = 3 
@export var narrator_pitch_scale : float = 3
@export var narrator_rate_speed : float = 3

##Volume preferences
@export var sound_mute := false
@export var master_volume : int = 3
@export var music_volume : int = 3
@export var SFX_volume : int = 3

##Gameplay preferences
@export var manual_inventory := false

func create() -> void:
	var res : userPrefs
	res = userPrefs.new()
	ResourceSaver.save(self, "user://user_prefs.tres")

static func load_or_create() -> userPrefs:
	var res : userPrefs = load("user://user_prefs.tres") as userPrefs
	if !res:
		res = userPrefs.new()
	return res

static func create_() -> userPrefs:
	var res = userPrefs.new()
	return res

static func save_exists() -> bool :
	var res : userPrefs = load("user://user_prefs.tres") as userPrefs
	if res:
		return true
	else:
		return false

func save() -> void:
	ResourceSaver.save(self, "user://user_prefs.tres")
