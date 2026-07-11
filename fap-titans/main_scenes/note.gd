extends Area2D

@export var lifetime: float = 2.0
var time_left: float = 0.0
var is_hit: bool = false
var is_missed: bool = false

func _ready():
	time_left = lifetime
	add_to_group("notes")
	input_pickable = true   # IMPORTANT

func _process(delta):
	if is_hit or is_missed: return
	time_left -= delta
	if time_left <= 0:
		miss_note()

func miss_note():
	if not is_hit and not is_missed:
		is_missed = true
		RhythmManager.register_miss()
		queue_free()

# === NEW: Direct click handling ===
func _input_event(viewport, event, shape_idx):
	if is_hit or is_missed: return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_viewport().set_input_as_handled()
		hit_success()

func hit_success():
	if not is_hit:
		is_hit = true
		JudgmentManager.judge_stationary_note(self, self.time_left)  # Pass time_left
		queue_free()
