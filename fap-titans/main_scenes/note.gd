extends Area2D

var speed: float = 300.0
var hit = false

func _physics_process(delta):
	position.y += speed * delta
	if position.y > 800:  # off screen
		queue_free()

func _on_area_entered(area):
	if area.is_in_group("hit_line") and not hit:
		hit = true
		# Signal to RhythmManager that note was hit
		queue_free()
