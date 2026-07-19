extends Node

@export var bpm: float = 60.0
var beat_interval: float = 0.0
var time_since_last_beat: float = 0.0
var is_active: bool = false

var game_time: float = 0.0

# === Spatial Spread Settings ===
@export var min_spawn_width: float = 300.0   # Early game - notes close together
@export var max_spawn_width: float = 900.0   # Late game - notes very spread out

signal note_hit(accuracy: String)
signal note_missed

func _ready():
	beat_interval = 60.0 / bpm

func _process(delta):
	if not is_active:
		return
	
	game_time += delta
	time_since_last_beat += delta
	
	if time_since_last_beat >= beat_interval:
		spawn_note()
		time_since_last_beat -= beat_interval

# ==================== DYNAMIC SPREAD ====================
func get_current_spawn_width() -> float:
	if game_time < 10.0:
		return min_spawn_width                     # Very clustered
	elif game_time < 30.0:
		# Gradually spread out
		var progress = (game_time - 10.0) / 20.0
		return lerp(min_spawn_width, max_spawn_width, progress)
	else:
		return max_spawn_width                     # Maximum spread

func spawn_note():
	var note = preload("res://main_scenes/note.tscn").instantiate()
	
	var spawn_width = get_current_spawn_width()
	var spawn_height = 120.0   # You can also make height spread if you want
	
	var center_x = 640
	var center_y = 280
	
	var random_x = center_x + randf_range(-spawn_width/2, spawn_width/2)
	var random_y = center_y + randf_range(-spawn_height/2, spawn_height/2)
	
	note.position = Vector2(random_x, random_y)
	get_tree().current_scene.add_child(note)

# Keep your other functions unchanged
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
	print("Rhythm System Started - Dynamic Spread Enabled")

func stop_game():
	is_active = false
	for note in get_tree().get_nodes_in_group("notes"):
		note.queue_free()
	print("Rhythm System Stopped")
