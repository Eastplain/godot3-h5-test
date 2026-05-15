extends Control

func _ready():
	update()

func _draw():
	var h = rect_size.y
	var w = h * 9.0 / 16.0
	var x = (rect_size.x - w) / 2.0
	draw_rect(Rect2(x, 0, w, h), Color(1, 0.1, 0.1, 1), false, 4.0)
