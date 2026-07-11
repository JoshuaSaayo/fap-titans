extends Node2D

@export var max_hp: float = 100.0
var current_hp: float = 100.0

@onready var hp_bar = $ProgressBar
@onready var sprite = $Sprite2D

var combo: int = 0
@onready var combo_label = $ComboLabel if has_node("ComboLabel") else null

signal player_died
signal combo_updated(new_combo)

func _ready():
	hp_bar.max_value = max_hp
	update_hp_ui()
	reset_combo()
	PlayerManager.register_player(self)

func take_damage(amount: float):
	current_hp = clamp(current_hp - amount, 0, max_hp)
	update_hp_ui()
	
	# Visual feedback
	sprite.modulate = Color.RED
	await get_tree().create_timer(0.15).timeout
	sprite.modulate = Color.WHITE
	
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
	if combo_label:
		combo_label.text = "COMBO x" + str(combo)
		combo_label.scale = Vector2(1.3, 1.3)
		var tween = create_tween()
		tween.tween_property(combo_label, "scale", Vector2(1,1), 0.3)
	emit_signal("combo_updated", combo)

func reset_combo():
	combo = 0
	if combo_label:
		combo_label.text = ""
	emit_signal("combo_updated", 0)

func get_combo_multiplier() -> float:
	return 1.0 + (combo * 0.05)  # +5% damage per combo
