extends Node2D

# 32 / 4 + 64 / 2 + 32 * 3 / 4 + 96 = 160 - number of all notes to spawn during music
@export var max_hp: float = 160.0
var current_hp: float = 160.0

@onready var spine: SpineSprite = $MinervaSpine
@onready var hp_bar = $ProgressBar

enum Phase { CLOTHED, DAMAGED, NUDE }
var current_phase = Phase.CLOTHED

func _ready():
	play_idle_animation()
	hp_bar.max_value = max_hp
	current_hp = max_hp
	update_hp_ui()
	apply_skin()          # Initial skin

func play_idle_animation():
	spine.get_animation_state().set_animation("animation", true, 0)

func take_damage(amount: float):
	current_hp = clamp(current_hp - amount, 0, max_hp)
	update_hp_ui()
	check_and_change_phase()

func update_hp_ui():
	hp_bar.value = current_hp

func check_and_change_phase():
	var hp_percent = (current_hp / max_hp) * 100
	var new_phase = current_phase
	
	if hp_percent >= 75:
		new_phase = Phase.CLOTHED
	elif hp_percent >= 35:
		new_phase = Phase.DAMAGED
	else:
		new_phase = Phase.NUDE
	
	if new_phase != current_phase:
		current_phase = new_phase
		apply_skin()

func apply_skin():
	if spine == null:
		return

	var skin_name := ""

	match current_phase:
		Phase.CLOTHED:
			skin_name = "clothed"
		Phase.DAMAGED:
			skin_name = "damaged"
		Phase.NUDE:
			skin_name = "nude"

	var skeleton = spine.get_skeleton()

	skeleton.set_skin_by_name(skin_name)
	skeleton.set_slots_to_setup_pose()

	print("Skin changed to: ", skin_name)
