extends Node2D

@onready var monster: Node2D = $monster
@onready var player: Node2D = $player

func _ready():
	# Extra safety registration
	RhythmManager.start_game()
	if not PlayerManager.player:
		PlayerManager.register_player(player)
	if not MonsterManager.monster:
		MonsterManager.register_monster(monster)
	
	print("Rhythm Prototype Started!")
	
	# Optional: Start music
	# $MusicPlayer.play()

func _process(delta):
	# Game Over Check
	if player.current_hp <= 0:
		print("Game Over - Player Defeated")
		get_tree().paused = true
	
	if monster.current_hp <= 0:
		get_tree().change_scene_to_file("res://animations/scenes/minerva_ls.tscn")
		

func _on_pause_btn_pressed() -> void:
	if PauseManager.is_paused: 
		return
	
	PauseManager.toggle_pause()
	
	var pause_menu = load("res://UI/pause_menu.tscn").instantiate()
	$UILayer.add_child(pause_menu)   # ← Add to CanvasLayer instead
