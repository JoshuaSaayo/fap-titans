extends Node2D

@onready var monster: Node2D = $monster
@onready var player: Node2D = $player
@onready var dialogue_box: Panel = $dialogue_box
@onready var dialogue_label: Label = $dialogue_box/DialogueLabel

var dialogue_data := {}
var current_dialogue: Array = []
var dialogue_index := 0
var is_in_dialogue := false
var has_triggered_victory := false
var outro_started = false
var scene_changed = false

func _ready():
	RhythmManager.start_game()

	if !PlayerManager.player:
		PlayerManager.register_player(player)

	if !MonsterManager.monster:
		MonsterManager.register_monster(monster)

	print("Rhythm Prototype Started!")

	load_dialogue_data()
	show_dialogue("minerva", "intro")


func load_dialogue_data():
	var file := FileAccess.open("res://dialogue/monsters_dialogue.json", FileAccess.READ)
	if !file:
		return

	dialogue_data = JSON.parse_string(file.get_as_text())
	file.close()


# ==================== DIALOGUE SYSTEM ====================

func show_dialogue(character: String, type: String):
	if !dialogue_data.get(character, {}).has(type):
		print("ERROR: Dialogue not found - ", character, "/", type)
		return

	current_dialogue = dialogue_data[character][type]
	dialogue_index = 0
	is_in_dialogue = true
	dialogue_box.show()

	print("Starting dialogue: ", type.to_upper())

	RhythmManager.stop_game()
	show_next_line()


func show_next_line():
	if dialogue_index >= current_dialogue.size():
		print("Dialogue finished!")
		end_dialogue()
		return

	dialogue_label.text = current_dialogue[dialogue_index]

	print(
		"Dialogue line ",
		dialogue_index + 1,
		"/",
		current_dialogue.size(),
		": ",
		current_dialogue[dialogue_index].substr(0, 50)
	)

	dialogue_index += 1


func end_dialogue():
	print("end_dialogue() called")

	dialogue_box.hide()
	is_in_dialogue = false
	current_dialogue.clear()

	if monster.current_hp > 0:
		print("Intro finished → Starting rhythm")
		RhythmManager.start_game()
		return

	if has_triggered_victory:
		return

	if scene_changed:
		return

	scene_changed = true

	print("✅ Outro finished → Loading Lewd Scene in 1 second...")

	await get_tree().create_timer(1.2).timeout

	print("Attempting scene change now...")

	await FadeTransition.fade_to_scene("res://animations/scenes/minerva_ls.tscn")


# ==================== INPUT ====================

func _input(event):
	if (
		is_in_dialogue
		and event is InputEventMouseButton
		and event.pressed
		and event.button_index == MOUSE_BUTTON_LEFT
	):
		show_next_line()


# ==================== GAME LOOP ====================

func _process(_delta):
	if player.current_hp <= 0:
		get_tree().change_scene_to_file("res://UI/game_over.tscn")
		return

	if monster.current_hp <= 0 and !outro_started:
		outro_started = true
		show_dialogue("minerva", "outro")
