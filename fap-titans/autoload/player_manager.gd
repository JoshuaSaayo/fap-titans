extends Node

var player: Node = null   # Will reference the actual Player node

func register_player(p: Node):
	player = p
	print("Player registered to PlayerManager")

# Helper functions (clean global access)
func take_damage(amount: float):
	if player:
		player.take_damage(amount)

func add_combo():
	if player:
		player.add_combo()

func reset_combo():
	if player:
		player.reset_combo()

func get_combo_multiplier() -> float:
	if player:
		return player.get_combo_multiplier()
	return 1.0
