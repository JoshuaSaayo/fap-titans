extends Node2D

@export var max_hp: float = 100.0
var current_hp: float = 100.0

@onready var hp_bar = $ProgressBar
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var slash_sound: AudioStreamPlayer = $SlashSound

var combo: int = 0
@onready var combo_label: Label = $Panel/ComboLabel

signal player_died
signal combo_updated(new_combo)

func _ready():
	hp_bar.max_value = max_hp
	update_hp_ui()
	reset_combo()
	PlayerManager.register_player(self)
	if anim:
		anim.play("idle")               # Start with idle


func take_damage(amount: float):
	current_hp = clamp(current_hp - amount, 0, max_hp)
	update_hp_ui()
	
	# Visual feedback
	anim.modulate = Color.RED
	await get_tree().create_timer(0.15).timeout
	anim.modulate = Color.WHITE
	
	if current_hp <= 0:
		emit_signal("player_died")

func heal(amount: float):
	current_hp = clamp(current_hp + amount, 0, max_hp)
	update_hp_ui()

func update_hp_ui():
	hp_bar.value = current_hp
	hp_bar.modulate = Color.GREEN if current_hp > max_hp * 0.4 else Color.RED

# Combo System
func add_combo():
	combo += 1
	update_combo_ui()
	emit_signal("combo_updated", combo)

func reset_combo():
	combo = 0
	update_combo_ui()
	emit_signal("combo_updated", 0)

func update_combo_ui():
	if combo_label:
		if combo >= 3:                          # Show only after some hits
			combo_label.text = "COMBO ×" + str(combo)
			combo_label.visible = true
		else:
			combo_label.visible = false

func get_combo():
	return combo

func get_combo_multiplier() -> float:
	return 1.0 + (combo * 0.05)  # +5% damage per combo

func play_slash_animation():
	if anim:
		anim.play("slash")
		slash_sound.play()
		
		# Return to idle after slash animation finishes
		await anim.animation_finished
		if anim.animation == "slash":
			anim.play("idle")
