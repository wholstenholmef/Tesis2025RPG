extends Node

var voices = DisplayServer.tts_get_voices_for_language("es")
var voice_id : String

var user_prefs_instance : userPrefs

func _ready() -> void:
	if voices.is_empty():
		return
	voice_id = voices[0]
	load_user_prefs()
	#print(voices)
	#DisplayServer.tts_speak("Menú de pausa", str(voice_id))

func load_user_prefs() -> void:
	user_prefs_instance = userPrefs.load_or_create()

func narrate(text : String, interrupt := false, override := false):
	if !user_prefs_instance.narrator_enabled:
		if !override:
			return
	
	if !user_prefs_instance:
		DisplayServer.tts_speak("error", str(voice_id))
	else:
		DisplayServer.tts_speak(text, \
		str(voice_id), \
		user_prefs_instance.narrator_volume * 20, \
		user_prefs_instance.narrator_pitch_scale / 3,\
		user_prefs_instance.narrator_rate_speed / 3, \
		0, \
		interrupt)
	print("Volumen: " + str(user_prefs_instance.narrator_volume * 20) + \
		  "pitch:" + str(user_prefs_instance.narrator_pitch_scale / 3) + \
		  "rate" + str(user_prefs_instance.narrator_rate_speed / 3))
