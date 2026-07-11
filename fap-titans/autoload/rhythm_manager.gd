extends Node

@export var bpm: float = 120.0
var beat_interval: float = 0.0
var time_since_last_beat: float = 0.0

signal note_hit(accuracy: String)
signal note_missed

func _ready():
	beat_interval = 60.0 / bpm

func _process(delta):
	time_since_last_beat += delta
	if time_since_last_beat >= beat_interval:
		spawn_note()
		time_since_last_beat -= beat_interval

func spawn_note():
	var note = preload("res://main_scenes/note.tscn").instantiate()
	
	# Spawn at fixed horizontal positions (Cytus style)
	var lanes = [400, 640, 880]   # 3 lanes for now
	var random_lane = lanes[randi() % lanes.size()]
	
	note.position = Vector2(random_lane, 300)   # Middle of screen vertically
	get_tree().current_scene.add_child(note)

func register_hit(accuracy: String = "perfect"):
	var damage = 25.0
	if accuracy == "perfect":
		damage = 40.0
	elif accuracy == "good":
		damage = 30.0
	
	damage *= PlayerManager.get_combo_multiplier()
	
	MonsterManager.take_damage(damage)
	PlayerManager.add_combo()
	
	emit_signal("note_hit", accuracy)

func register_miss():
	PlayerManager.take_damage(8.0)
	PlayerManager.reset_combo()
	emit_signal("note_missed")
