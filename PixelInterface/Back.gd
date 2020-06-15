tool
extends Control

func _ready() -> void:
	Utility.ok(get_node("..").connect("resized", self, "_onResized"))

func _onResized() -> void:
	var tex := rect_size
	var win := get_viewport_rect().size
	if win.x > win.y:
		rect_rotation = 90
		rect_scale = Vector2(win.y / tex.x, win.x / tex.y)
	else:
		rect_rotation = 0
		rect_scale = Vector2(win.x / tex.x, win.y / tex.y)
