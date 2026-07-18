extends Node2D

# @onready var sfx_moan: AudioStreamPlayer = $sfx_moan

# var character_moans: Dictionary = {
# 	"elara": [
# 		preload("res://anim/lewd_assets/lilith_ls_1/sounds/elara_moan1.wav"),
# 		preload("res://anim/lewd_assets/lilith_ls_1/sounds/elara_moan2.wav"),
# 		preload("res://anim/lewd_assets/lilith_ls_1/sounds/elara_moan3.wav")
# 	]
# }
const LOOP_COUNT: int = 5
var loops_done: int = 0
@onready var spine_sprite: SpineSprite = $SpineSprite

@export var character: String = "elara"
@export var preview_mode: bool = false

func _ready() -> void:
	RhythmManager.stop_game()
	spine_sprite.get_animation_state().set_animation("lewdscene", true, 0)
	spine_sprite.animation_completed.connect(_on_animation_completed)
	# Connect to the Sprite's signal, not the AnimationState's
# 	self.animation_event.connect(_on_animation_event)

func _on_animation_completed(_spine, _state, track_entry):
	match track_entry.get_animation().get_name():
		"lewdscene":
			loops_done += 1
			if loops_done >= LOOP_COUNT:
				spine_sprite.get_animation_state().set_animation("climax", false, 0)

		"climax":
			if preview_mode:
				pass
			else:
				climax_finished()

func climax_finished():
	
	# Go to ending scene
	await get_tree().create_timer(1.0).timeout  # Small delay for better feel
	FadeTransition.fade_to_scene("res://UI/end_transition.tscn")

func _on_pause_btn_pressed() -> void:
	if PauseManager.is_paused: 
		return
	
	PauseManager.toggle_pause()
	
	var pause_menu = load("res://UI/pause_menu.tscn").instantiate()
	$UILayer.add_child(pause_menu)   # ← Add to CanvasLayer instead
		
# func _on_animation_event(spine_sprite: SpineSprite, animation_state: SpineAnimationState, track_entry: SpineTrackEntry, event: SpineEvent) -> void:
	# Use get_data().get_event_name() to check the name defined in Spine
# 	if event.get_data().get_event_name() == "moan":
# 		play_random_moan()
		
# func play_random_moan():
# 	if not character_moans.has(character):
# 		return
	
# 	var moans = character_moans[character]
# 	if moans.is_empty():
# 		return
	
# 	var random_sound = moans.pick_random()
	
# 	sfx_moan.stream = random_sound
# 	sfx_moan.play()
