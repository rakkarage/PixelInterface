@tool
extends Control

@export var _cell_size := 4

func _draw() -> void:
	var s := get_viewport_rect().size
	for y in range(0, s.y, _cell_size):
		draw_line(Vector2(0, y), Vector2(s.x, y), Color(1, 1, 1, 0.5))
	for x in range(0, s.x, _cell_size):
		draw_line(Vector2(x, 0), Vector2(x, s.y), Color(1, 1, 1, 0.5))
