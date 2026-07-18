extends Node

@export var bpm: float = 120.0
var beat_interval: float = 0.0
var time_since_last_beat: float = 0.0
var is_active: bool = false

var game_time: float = 0.0

# Difficulty Settings
@export var start_spawn_rate: float = 1.8   # Slow at beginning (seconds between notes)
@export var mid_spawn_rate: float = 0.9     # Intermediate
@export var final_spawn_rate: float = 0.45  # Fast & intense

signal note_hit(accuracy: String)
signal note_missed

func _ready():
	beat_interval = 60.0 / bpm

func _process(delta):
	if not is_active:
		return
	
	game_time += delta
	time_since_last_beat += delta
	
	# Dynamic spawn rate based on time
	var current_spawn_rate = get_current_spawn_rate()
	
	if time_since_last_beat >= current_spawn_rate:
		spawn_note()
		time_since_last_beat -= current_spawn_rate

# ==================== DYNAMIC SPAWN RATE ====================
func get_current_spawn_rate() -> float:
	if game_time < 10.0:
		return start_spawn_rate           # First 10 seconds - Slow
	elif game_time < 30.0:
		# Linear interpolation between slow and medium
		var progress = (game_time - 10.0) / 20.0
		return lerp(start_spawn_rate, mid_spawn_rate, progress)
	else:
		return final_spawn_rate           # After 30 seconds - Fast & intense

func spawn_note():
	var note = preload("res://main_scenes/note.tscn").instantiate()
	
	var spawn_area_width = 600
	var spawn_area_height = 80
	var center_x = 640
	var center_y = 280
	
	var random_x = center_x + randf_range(-spawn_area_width/2, spawn_area_width/2)
	var random_y = center_y + randf_range(-spawn_area_height/2, spawn_area_height/2)
	
	note.position = Vector2(random_x, random_y)
	get_tree().current_scene.add_child(note)

# Rest of your functions (unchanged)
func register_hit(accuracy: String = "perfect"):
	var damage = 3.0
	if accuracy == "perfect":
		damage = 10.0
	elif accuracy == "good":
		damage = 5.0
	damage *= PlayerManager.get_combo_multiplier()
	MonsterManager.take_damage(damage)
	emit_signal("note_hit", accuracy)

func register_miss():
	PlayerManager.take_damage(8.0)
	PlayerManager.reset_combo()
	emit_signal("note_missed")

func start_game():
	is_active = true
	game_time = 0.0
	time_since_last_beat = 0.0
	print("Rhythm System Started - Difficulty Ramp Enabled")

func stop_game():
	is_active = false
	for note in get_tree().get_nodes_in_group("notes"):
		note.queue_free()
	print("Rhythm System Stopped")
