extends Node

@export var bpm: float = 120.0
var beat_interval: float = 0.0
var time_since_last_beat: float = 0.0
var is_spawning: bool = false;

signal note_hit(accuracy: String)
signal note_missed

func _ready():
	beat_interval = 60.0 / bpm

func _process(delta):
	if !is_spawning:
		return
	
	time_since_last_beat += delta
	if time_since_last_beat >= beat_interval:
		spawn_note()
		time_since_last_beat -= beat_interval

func start_spawning():
	is_spawning = true;

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
	var damage = 25.0
	if accuracy == "perfect":
		damage = 40.0
	elif accuracy == "good":
		damage = 30.0
	
	damage *= PlayerManager.get_combo_multiplier()
	
	MonsterManager.take_damage(damage)
	
	emit_signal("note_hit", accuracy)

func register_miss():
	PlayerManager.take_damage(8.0)
	PlayerManager.reset_combo()
	emit_signal("note_missed")
