extends Node

var monster: Node = null   # Will reference the actual Monster node

func register_monster(m: Node):
	monster = m
	print("Monster registered to MonsterManager")

# Helper functions
func take_damage(amount: float):
	if monster:
		monster.take_damage(amount)

func get_hp_percent() -> float:
	if monster:
		return monster.current_hp / monster.max_hp
	return 1.0
