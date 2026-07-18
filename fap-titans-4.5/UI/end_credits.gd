extends Control

@onready var timer: Timer = $Timer
@onready var end_credits: Control = $EndCredits
@onready var sound_resources: Control = $SoundResources
@onready var fade_rect: ColorRect = $FadeRect

enum State { END_CREDITS, SOUND_CREDITS, DONE }
var current_state: State = State.END_CREDITS

func _ready():
	
	end_credits.visible = true
	sound_resources.visible = false
	fade_rect.modulate.a = 0
	
	timer.wait_time = 5.0
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _on_timer_timeout():
	match current_state:
		State.END_CREDITS:
			end_credits.visible = false
			sound_resources.visible = true
			current_state = State.SOUND_CREDITS
			timer.start()
			
		State.SOUND_CREDITS:
			current_state = State.DONE
			_fade_to_menu()

func _fade_to_menu():
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 1.5)
	await tween.finished
	
	get_tree().change_scene_to_file("res://UI/menu.tscn")
