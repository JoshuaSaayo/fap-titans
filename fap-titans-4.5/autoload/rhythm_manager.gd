extends Node

@export var bpm: float = 120.0
var beat_interval: float = 0.0
var time_since_last_beat: float = 0.0
var is_active: bool = false

signal note_hit(accuracy: String)
signal note_missed

func _ready():
	beat_interval = 60.0 / bpm

func _process(delta):
	if not is_active:
		return
	
	time_since_last_beat += delta
	if time_since_last_beat >= beat_interval:
		spawn_note()
		time_since_last_beat -= beat_interval

func spawn_note():
	var note = preload("res://main_scenes/note.tscn").instantiate()
	
	# === Random spawn inside a defined rectangle ===
	var spawn_area_width = 600     # How wide the spawn zone is
	var spawn_area_height = 80     # How tall (usually small)
	
	# Center point of spawn area (adjust these numbers to your liking)
	var center_x = 640
	var center_y = 280             # Higher = more towards top of screen
	
	# Random position inside the area
	var random_x = center_x + randf_range(-spawn_area_width/2, spawn_area_width/2)
	var random_y = center_y + randf_range(-spawn_area_height/2, spawn_area_height/2)
	
	note.position = Vector2(random_x, random_y)
	
	get_tree().current_scene.add_child(note)

func register_hit(accuracy: String = "perfect"):
	var damage = 5.0
	if accuracy == "perfect":
		damage = 20.0
	elif accuracy == "good":
		damage = 10.0
	
	damage *= PlayerManager.get_combo_multiplier()
	
	MonsterManager.take_damage(damage)
	
	emit_signal("note_hit", accuracy)

func register_miss():
	PlayerManager.take_damage(8.0)
	PlayerManager.reset_combo()
	emit_signal("note_missed")

func start_game():
	is_active = true
	time_since_last_beat = 0.0
	print("Rhythm System Started")

func stop_game():
	is_active = false
	# Optional: remove all existing notes
	for note in get_tree().get_nodes_in_group("notes"):
		note.queue_free()
	print("Rhythm System Stopped")
