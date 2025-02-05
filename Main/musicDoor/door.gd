extends StaticBody3D

var piano_music_notes_path = "res://Assets/SFX/MusicNotesPiano/"
var piano_music_notes = ["DO", "RE", "MI", "FA", "SOL", "LA", "SI"]
var file_suffix = ".wav"
var sequence_array = []
var input_array = []
var current_sequence_cursor = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gen_sequence()
	#for note in piano_music_notes: 
		#$NotePlayer.stream = load(str(piano_music_notes_path + note + file_suffix))
		#$NotePlayer.play()
		#await get_tree().create_timer(0.7).timeout

func gen_sequence():
	sequence_array = []
	for i in 3: 
		var random_note = piano_music_notes.pick_random()
		sequence_array.append(random_note)
		piano_music_notes.erase(random_note)
	print("la secuencia es: " + str(sequence_array))

func get_sequence(): 
	return sequence_array

func _on_music_instrument_note_played(note) -> void:
	if input_array.size() >= 3:
		input_array.remove_at(0)
	
	#if current_sequence_cursor < 3:
		#if note == sequence_array[current_sequence_cursor]:
			#current_sequence_cursor += 1
		#else: current_sequence_cursor = 0 
	#if current_sequence_cursor >= 3:
		#print("Ganaste!!!!!!!!")
	
	if input_array == sequence_array:
		print("wowzas!!!")
	
	input_array.append(note)
	print(input_array)
