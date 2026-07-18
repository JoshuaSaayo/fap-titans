extends Node2D

@onready var player: AudioStreamPlayer = %Player

var firstBeatPosition = 2.198
var bpm = 160.0
var beatDelta = 60.0 / bpm
var noteLifetime = 0.5
var prevBeatNumber = -1

var stage1From = 0
var stage1To = 31
var stage2From = 32
var stage2To = 95
var stage3From = 96
var stage3To = 127
var stage4From = 128
var stage4To = 223

func _process(delta: float) -> void:
	var music_position = player.get_playback_position()
	var beatPosition = music_position - firstBeatPosition
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

func on_start_press():
	player.play()
	pass

func spawn_note(beat: int):
	var note = preload("res://main_scenes/note.tscn").instantiate()
	
	note.position = Vector2(200 + 100 * (beat % 4), 200)
	note.lifetime = noteLifetime
	get_tree().current_scene.add_child(note)
