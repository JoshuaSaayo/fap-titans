extends Node2D

@onready var monster: Node2D = $monster
@onready var player: Node2D = $player
@onready var dialogue_label: Label = $dialogue_box/DialogueLabel
@onready var dialogue_box: Panel = $dialogue_box

var dialogue_data = {}
var current_dialogue: Array = []
var dialogue_index: int = 0

func _ready():
	RhythmManager.start_game()
	
	if not PlayerManager.player:
		PlayerManager.register_player(player)
	if not MonsterManager.monster:
		MonsterManager.register_monster(monster)
	
	print("Rhythm Prototype Started!")
	
	# Load dialogue data
	load_dialogue_data()
	
	# Show Intro Dialogue
	show_dialogue("minerva", "intro")

func load_dialogue_data():
	var file = FileAccess.open("res://dialogue/monsters_dialogue.json", FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		dialogue_data = JSON.parse_string(json_text)
		file.close()
	else:
		print("ERROR: Could not load dialogue JSON!")

func show_dialogue(character: String, type: String):
	if not dialogue_data.has(character) or not dialogue_data[character].has(type):
		print("Dialogue not found: ", character, " - ", type)
		return
	
	current_dialogue = dialogue_data[character][type]
	dialogue_index = 0
	dialogue_box.visible = true
	show_next_line()

func show_next_line():
	if dialogue_index < current_dialogue.size():
		dialogue_label.text = current_dialogue[dialogue_index]
		dialogue_index += 1
	else:
		# Dialogue finished
		dialogue_box.visible = false
		current_dialogue.clear()

func _input(event):
	if event is InputEventMouseButton and event.pressed and dialogue_box.visible:
		if event.button_index == MOUSE_BUTTON_LEFT:
			show_next_line()

# ==================== VICTORY ====================
func _process(delta):
	if player.current_hp <= 0:
		get_tree().change_scene_to_file("res://UI/game_over.tscn")
	
	if monster.current_hp <= 0 and current_dialogue.is_empty():  # Only trigger once
		show_dialogue("minerva", "outro")
		# Wait until outro dialogue finishes before going to lewd scene
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://animations/scenes/minerva_ls.tscn")
