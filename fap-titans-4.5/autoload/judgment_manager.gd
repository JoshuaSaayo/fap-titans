extends Node

@export var perfect_window: float = 0.12
@export var good_window: float = 0.25

func _input(event):
	if event is InputEventScreenTouch and event.pressed:
		pass#attempt_hit(event.position)
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		pass#attempt_hit(event.position)

func attempt_hit(touch_pos):
	var notes = get_tree().get_nodes_in_group("notes")
	for note in notes:
		if note.is_hit or not note.is_tappable:
			continue
		
		var distance = note.global_position.distance_to(touch_pos)
		if distance < 130:   # Slightly bigger touch area for mobile
			judge_stationary_note(note, note.time_left)
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
