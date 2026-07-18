extends Control

@onready var start_btn: Button = $StartBtn
@onready var settings_btn: Button = $SettingsBtn
@onready var credits_btn: Button = $CreditsBtn
@onready var exit_btn: Button = $ExitBtn
@onready var settings: Control = $Settings
@onready var credits: Control = $Credits
@onready var logo: Sprite2D = $Logo
@onready var exit: Control = $Exit
@onready var display_panel: Panel = $Settings/DisplayPanel
@onready var audio_panel: Panel = $Settings/AudioPanel


func _ready() -> void:
	RhythmManager.stop_game()
	exit.visible = false
	credits.visible = false
	settings.visible = false
	_set_ui_visible(true, [start_btn, settings_btn, credits_btn, exit_btn, logo])

func _set_ui_visible(visible: bool, nodes: Array) -> void:
	for node in nodes:
		node.visible = visible
		
		
func _on_start_btn_pressed() -> void:
	await FadeTransition.fade_to_scene("res://main_scenes/main.tscn")


func _on_settings_btn_pressed() -> void:
	settings.visible = true
	_set_ui_visible(false, [start_btn, settings_btn, credits_btn, exit_btn, logo, exit])

func _on_display_btn_pressed() -> void:
	display_panel.visible = true
	audio_panel.visible = false


func _on_audio_btn_pressed() -> void:
	display_panel.visible = false
	audio_panel.visible = true
	
func _on_settings_close_btn_pressed() -> void:
	settings.visible = false
	exit.visible = false
	_set_ui_visible(true, [start_btn, settings_btn, credits_btn, exit_btn, logo])
	
func _on_credits_btn_pressed() -> void:
	_set_ui_visible(false, [start_btn, settings_btn, credits_btn, exit_btn, logo, exit])
	credits.visible = true

func _on_credits_close_btn_pressed() -> void:
	credits.visible = false
	exit.visible = false
	_set_ui_visible(true, [start_btn, settings_btn, credits_btn, exit_btn, logo])

func _on_exit_btn_pressed() -> void:
	exit.visible = true


func _on_yes_btn_pressed() -> void:
	get_tree().quit()


func _on_no_btn_pressed() -> void:
	exit.visible = false
