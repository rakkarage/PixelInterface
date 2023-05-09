@tool
extends Control

const _r = PI/2

func _ready() -> void:
	get_node("..").connect("resized", _onResized)
	_onResized()

func _onResized() -> void:
	var tex := size
	var win := get_viewport_rect().size
	if win.x > win.y:
		rotation = _r
		scale = Vector2(win.y / tex.x, win.x / tex.y)
	else:
		rotation = 0
		scale = Vector2(win.x / tex.x, win.y / tex.y)
