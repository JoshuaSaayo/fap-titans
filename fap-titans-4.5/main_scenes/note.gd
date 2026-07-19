extends Area2D

@export var lifetime: float = 2.0      # Total time the note exists
@export var fade_in_time: float = 0.4  # Time to go from 0% to 100% opacity

var time_left: float = 0.0
var is_hit: bool = false
var is_missed: bool = false
var is_tappable: bool = false

@onready var sprite = $Sprite2D          # Make sure you have a Sprite2D as child

signal on_free

func _ready():
	time_left = lifetime
	add_to_group("notes")
	input_pickable = true
	
	if sprite:
		sprite.modulate.a = 0.0   # Start fully transparent

func _process(delta):
	if is_hit or is_missed: return
	
	time_left -= delta
	
	# === Fade In Logic ===
	var progress = 1.0 - (time_left / lifetime)           # 0.0 → 1.0
	var alpha = clamp(progress * (1.0 / fade_in_time), 0.0, 1.0)
	
	if sprite:
		sprite.modulate.a = alpha
	
	# Become tappable only when almost or fully visible
	if alpha >= 0.95 and not is_tappable:
		is_tappable = true
	
	if time_left <= 0:
		miss_note()

func miss_note():
	if not is_hit and not is_missed:
		is_missed = true
		RhythmManager.register_miss()
		on_free.emit()
		queue_free()

# === Click / Tap Handling ===
func _input_event(viewport, event, shape_idx):
	if not is_tappable or is_hit or is_missed: 
		return
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_viewport().set_input_as_handled()
		hit_success()

func hit_success():
	if not is_hit:
		is_hit = true
		
		spawn_hit_effect()
		
		# === Trigger Combo & Slash ===
		if PlayerManager.player:
			PlayerManager.player.add_combo()           # ← Add this
			PlayerManager.player.play_slash_animation() # ← Already had this
		
		JudgmentManager.judge_stationary_note(self, self.time_left)
		on_free.emit()
		queue_free()

func spawn_hit_effect():
	var effect_scene = preload("res://main_scenes/hit_effect.tscn")
	var effect = effect_scene.instantiate()
	effect.position = self.global_position
	effect.emitting = true
	get_tree().current_scene.add_child(effect)
	
	# Auto free after lifetime
	await get_tree().create_timer(1.0).timeout
	on_free.emit()
	effect.queue_free()
