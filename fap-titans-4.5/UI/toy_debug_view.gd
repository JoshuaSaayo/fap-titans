extends Control

var data: Array[float] = []
var start: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in 100:
		data.append(0)
	
	pass # Replace with function body.
	
func _process(delta: float) -> void:
	start = (start + 1) % data.size()
	var level = ToysManager.vibrationLevel.get_value()
	data[start] = level
	queue_redraw()
	#data[]
	#vibrationLevel.setValue(RandomNumberGenerator.new().readf())

func _draw() -> void:
	var width = size.x
	var height = size.y
	var capHeight = 1
	var stepX = 2#(width - 2) / data.size()
	var xStart: float = 1 + width - data.size() * stepX
	var yStart: float = 1 + capHeight
	var stepY = (height - 1 - yStart)
	
	draw_rect(Rect2(1, 1, width-1, height-1), Color.BLACK, true)
	for i in data.size():
		var value = data[(start + i + 1) % data.size()]
		draw_rect(Rect2(xStart + stepX * i, yStart + stepY * (1 - value), stepX - 1, stepY * value), Color.WEB_PURPLE, true)
		draw_rect(Rect2(xStart + stepX * i, yStart + stepY * (1 - value) - capHeight, stepX - 1, capHeight), Color.DEEP_PINK, true)
