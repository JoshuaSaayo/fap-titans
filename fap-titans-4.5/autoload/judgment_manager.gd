extends Node

@export var perfect_window: float = 0.12
@export var good_window: float = 0.25

func _input(event):
	if event is InputEventScreenTouch or (event is InputEventKey and event.pressed):
		if event is InputEventKey and event.keycode not in [KEY_SPACE, KEY_Z, KEY_J]:
			return
		#attempt_hit(event.position if event is InputEventScreenTouch else null)

func attempt_hit(touch_pos = null):
	var notes = get_tree().get_nodes_in_group("notes")
	for note in notes:
		if note.is_hit: continue
		
		var distance = note.global_position.distance_to(touch_pos) if touch_pos != null else 0
		
		if touch_pos == null or distance < 120:   # Click/Tap within range
			var timing = note.time_left
			judge_stationary_note(note, timing)
			return

# FIXED: Now accepts 2 arguments
func judge_stationary_note(note: Node, time_left: float):
	var ideal = note.lifetime / 2.0
	var timing_error = abs(time_left - ideal)
	
	if timing_error <= perfect_window:
		RhythmManager.register_hit("perfect")
	elif timing_error <= good_window:
		RhythmManager.register_hit("good")
	else:
		RhythmManager.register_hit("bad")
