@tool
extends Control

var _w := 0.0
var _h := 0.0
const _cell := 4

func _ready() -> void:
	var r := get_viewport_rect()
	_w = r.size.x
	_h = r.size.y

func _draw() -> void:
	for y in range(0, _h, _cell):
		draw_line(Vector2(0, y), Vector2(_w, y), Color(1, 1, 1, 0.5))
	for x in range(0, _w, _cell):
		draw_line(Vector2(x, 0), Vector2(x, _h), Color(1, 1, 1, 0.5))
