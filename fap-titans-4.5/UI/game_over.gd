extends Control

@onready var reason_label: Label = $ReasonLabel

func _ready() -> void:
	RhythmManager.stop_game()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func set_reason(reason: String):
	var reason_label = get_node_or_null("Panel/ReasonLabel")
	if reason_label:
		reason_label.text = reason
	else:
		print("Could not find ReasonLabel. Reason was: " + reason)

func _on_restart_btn_pressed() -> void:
	await FadeTransition.fade_to_scene("res://main_scenes/main.tscn")


func _on_main_menu_pressed() -> void:
	await FadeTransition.fade_to_scene("res://UI/menu.tscn")
