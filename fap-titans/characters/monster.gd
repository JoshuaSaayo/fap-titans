extends Node2D

@export var max_hp: float = 1000.0
var current_hp: float = 1000.0

@onready var hp_bar = $ProgressBar
@onready var sprite = $Sprite2D

enum Phase { FULL, HALF, LOW }
var current_phase = Phase.FULL

func _ready():
	hp_bar.max_value = max_hp
	update_hp(0)

func take_damage(amount: float):
	current_hp = clamp(current_hp - amount, 0, max_hp)
	update_hp(0)
	check_phase()

func update_hp(_delta):
	hp_bar.value = current_hp

func check_phase():
	var hp_percent = current_hp / max_hp
	
	if hp_percent > 0.6 and current_phase != Phase.FULL:
		current_phase = Phase.FULL
		change_form(0)  # Full armor / clothed
	elif hp_percent > 0.3 and hp_percent <= 0.6 and current_phase != Phase.HALF:
		current_phase = Phase.HALF
		change_form(1)  # Partially stripped
	elif hp_percent <= 0.3 and current_phase != Phase.LOW:
		current_phase = Phase.LOW
		change_form(2)  # Almost nude / lewd

func change_form(phase_index: int):
	# TODO: Change texture or animation here
	print("Monster changed to Phase ", phase_index)
	# Example: sprite.texture = load("res://sprites/monster/phase_" + str(phase_index) + ".png")
