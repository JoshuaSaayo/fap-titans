extends Node

@export var bpm: float = 120.0
var beat_interval: float
var time_since_last_beat: float = 0.0

@onready var monster = $"../Monster"
@onready var spawn_point = $"../NoteSpawnPoint"  # Position2D at top

signal note_hit(accuracy)
signal note_missed

func _ready():
	beat_interval = 60.0 / bpm

func _process(delta):
	time_since_last_beat += delta
	if time_since_last_beat >= beat_interval:
		spawn_note()
		time_since_last_beat = 0.0

func spawn_note():
	var note = preload("res://main_scenes/note.tscn").instantiate()
	note.position = spawn_point.position + Vector2(randf_range(-100, 100), 0)
	add_child(note)

# Call this from input when player hits note
func process_hit():
	monster.take_damage(25)  # Adjust damage
	emit_signal("note_hit", "perfect")

func process_miss():
	emit_signal("note_missed")
	# Player takes damage here
