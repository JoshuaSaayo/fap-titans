extends Node2D

@onready var monster: Node2D = $monster
@onready var player: Node2D = $player

func _ready():
	# Extra safety registration
	if not PlayerManager.player:
		PlayerManager.register_player(player)
	if not MonsterManager.monster:
		MonsterManager.register_monster(monster)
	
	RhythmManager.start_spawning()
	
	print("Rhythm Prototype Started!")
	
	# Optional: Start music
	# $MusicPlayer.play()

func _process(delta):
	# Game Over Check
	if player.current_hp <= 0:
		print("Game Over - Player Defeated")
		get_tree().paused = true
	
	if monster.current_hp <= 0:
		print("Victory! Monster Defeated")
		get_tree().paused = true
