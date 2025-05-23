extends Node3D

@export var active := true

var piano_music_notes_path = "res://Assets/SFX/MusicNotesPiano/"
var flute_music_notes_path = "res://Assets/SFX/MusicNotesFlute/"
var piano_music_notes = ["DO", "RE", "MI", "FA", "SOL", "LA", "SI"]
var file_suffix = ".wav"

var note1
var note2
var note3
var current_notes := []

signal note_played


func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	current_notes = get_parent().get_node("Door").get_sequence()
	 
	note1 = load(str(flute_music_notes_path + current_notes[0] + file_suffix)) 
	note2 = load(str(flute_music_notes_path + current_notes[1] + file_suffix)) 
	note3 = load(str(flute_music_notes_path + current_notes[2] + file_suffix)) 


func _process(delta: float) -> void:
	if !active:
		return
	if Input.is_action_just_pressed("left"): 
		if current_notes.is_empty(): return
		note_played.emit(current_notes[0])
		$musicInstrumentPlayer.stream = note1
		$musicInstrumentPlayer.play()
	if Input.is_action_just_pressed("forward"): 
		if current_notes.is_empty(): return
		note_played.emit(current_notes[1])
		$musicInstrumentPlayer.stream = note2
		$musicInstrumentPlayer.play()
	if Input.is_action_just_pressed("right"): 
		if current_notes.is_empty(): return
		note_played.emit(current_notes[2])
		$musicInstrumentPlayer.stream = note3
		$musicInstrumentPlayer.play()
