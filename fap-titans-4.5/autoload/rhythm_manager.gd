extends Node

@export var bpm: float = 160.0
var beat_interval: float = 0.0
var time_since_last_beat: float = 0.0
var is_active: bool = false

var game_time: float = 0.0

# === Spatial Spread Settings ===
@export var min_spawn_width: float = 300.0   # Early game - notes close together
@export var max_spawn_width: float = 900.0   # Late game - notes very spread out


signal note_hit(accuracy: String)
signal note_missed


var firstBeatPosition = 2.198
var beatDelta = 60.0 / bpm
var noteLifetime = 0.8
var prevBeatNumber = -1

var stage1From = 0
var stage1To = 31
var stage2From = 32
var stage2To = 95
var stage3From = 96
var stage3To = 127
var stage4From = 128
var stage4To = 223

var visibleNotes: Array[Node] = []

func _ready():
	beat_interval = 60.0 / bpm

#func _process(delta):
	#if not is_active:
		#return
	#
	#game_time += delta
	#time_since_last_beat += delta
	#
	#if time_since_last_beat >= beat_interval:
		#spawn_note()
		#time_since_last_beat -= beat_interval

# ==================== DYNAMIC SPREAD ====================
func get_current_spawn_width() -> float:
	return max_spawn_width
	
	#if game_time < 10.0:
		#return min_spawn_width                     # Very clustered
	#elif game_time < 30.0:
		## Gradually spread out
		#var progress = (game_time - 10.0) / 20.0
		#return lerp(min_spawn_width, max_spawn_width, progress)
	#else:
		#return max_spawn_width                     # Maximum spread

func spawn_note(beat_number: int):
	var note = preload("res://main_scenes/note.tscn").instantiate()
	
	var spawn_width = get_current_spawn_width()
	var spawn_height = 120.0   # You can also make height spread if you want
	
	var center_x = 640
	var center_y = 280
	var min_distance = 100
	
	var options: Array[Vector2]
	while options.size() < 3:
		var random_x = center_x + randf_range(-spawn_width/2, spawn_width/2)
		var random_y = center_y + randf_range(-spawn_height/2, spawn_height/2)
		var random_v = Vector2(random_x, random_y)
		
		var hasIntersection = visibleNotes.any(
			func (visibleNote: Node):
				var dist = visibleNote.position.distance_to(random_v)
				return dist < min_distance
		)
		
		if (!hasIntersection):
			options.append(random_v)
	
	options.sort_custom(
		func (a: Vector2, b: Vector2):
			var minDistanceA = 9000
			var minDistanceB = 9000
			
			for visiblewNote in visibleNotes:
				var distanceA = visiblewNote.position.distance_to(a)
				if (distanceA < minDistanceA):
					minDistanceA = distanceA
					
				var distanceB = visiblewNote.position.distance_to(b)
				if (distanceB < minDistanceB):
					minDistanceB = minDistanceB
					
			return minDistanceA < minDistanceB
	)
	
	note.lifetime = noteLifetime
	note.position = options[0]
	note.on_free.connect(
		func ():
			visibleNotes = visibleNotes.filter(
				func (visibleNote):
					return visibleNote != note
			)
	)
	get_tree().current_scene.add_child(note)
	visibleNotes.append(note)

# Keep your other functions unchanged
func register_hit(accuracy: String = "perfect"):
	var damage = 1.0
	#if accuracy == "perfect":
		#damage = 10.0
	#elif accuracy == "good":
		#damage = 5.0
	#damage *= PlayerManager.get_combo_multiplier()
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

func update_with_music_position(music_position: float):
	if not is_active:
		return
	
	var beatPosition = music_position - firstBeatPosition
	
	ToysManager.update_for_music(beatPosition, beatDelta, 0)
	
	var beatSpawnPosition = beatPosition + noteLifetime
	var beatNumber = int(floor(beatSpawnPosition / beatDelta))
	if (beatNumber != prevBeatNumber && beatNumber >= 0):
		prevBeatNumber = beatNumber
		#print(beatNumber)

		var isTick1 = beatNumber % 4 == 0
		var isTick2 = beatNumber % 4 == 1
		var isTick3 = beatNumber % 4 == 2
		var isTick4 = beatNumber % 4 == 3
		
		var isStage1 = beatNumber >= stage1From && beatNumber <= stage1To
		var isStage2 = beatNumber >= stage2From && beatNumber <= stage2To
		var isStage3 = beatNumber >= stage3From && beatNumber <= stage3To
		var isStage4 = beatNumber >= stage4From && beatNumber <= stage4To
		
		#spawn_note(beatNumber)
		
		if (isStage1):
			if (isTick1):
				spawn_note(beatNumber)
		elif (isStage2):
			if (isTick1 || isTick3):
				spawn_note(beatNumber)
		elif (isStage3):
			if (isTick1 || isTick2 || isTick3):
				spawn_note(beatNumber)
		elif (isStage4):
			if (isTick1 || isTick2 || isTick3 || isTick4):
				spawn_note(beatNumber)
