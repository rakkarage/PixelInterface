extends Control

@onready var _preview := $TexturePreview
@onready var _atlas := $TextureAtlas
@export_file("*.fnt") var _fontData: String
var _characters: Dictionary
var _imagePath: String
var _lineHeight: int
var _base: int
var _zoomFactor := 1.1
var _points : Array

func _ready() -> void:
	if _fontData.is_empty():
		printerr("Set font file in inspector.")
		return
	_parseFont()
	_points = [
		Vector2(0, -_lineHeight + _base + 0.5), Vector2(600, - _lineHeight + _base + 0.5),
		Vector2(0, -_lineHeight + 0.5), Vector2(600, -_lineHeight + 0.5),
		Vector2(0, 0.5), Vector2(600, 0.5)
	]
	_preview.connect("draw", _drawPreview)
	_atlas.texture = load(_fontData.get_base_dir() + "/" + _imagePath)
	_atlas.scale = Vector2(4, 4)
	_atlas.connect("draw", _drawAtlas)

func _parseFont() -> void:
	var file = FileAccess.open(_fontData, FileAccess.READ)
	if not file: return
	parseHeader()
	while !file.eof_reached():
		var line := file.get_line().strip_edges()
		if line.begins_with("chars count"): continue
		if line.begins_with("char"):
			var info := parseLine(line)
			var charCode: int = info["id"]
			_characters[charCode] = info

func parseHeader() -> void:
	var file = FileAccess.open(_fontData, FileAccess.READ)
	if not file: return
	while !file.eof_reached():
		var line = file.get_line()
		if line.begins_with("page id=0"):
			var info := parseLine(line)
			_imagePath = info["file"].replace("\"", "")
		if line.begins_with("common"):
			var info := parseLine(line)
			_lineHeight = info["lineHeight"]
			_base = info["base"]

func parseLine(line: String) -> Dictionary:
	var info := {}
	var data := line.split(" ")
	for item in data:
		var parts := item.split("=")
		if parts.size() > 1:
			var key := parts[0].strip_edges()
			var value = parts[1]
			if key != "file":
				value = value.to_int()
			info[key] = value
	return info

func _drawPreview() -> void:
	var text := "! !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"
	_preview.draw_line(_points[0], _points[1], Color(1, 0, 0, 0.5), 1)
	_preview.draw_line(_points[2], _points[3], Color(0, 0, 1, 0.5), 1)
	_preview.draw_line(_points[4], _points[5], Color(0, 0, 1, 0.5), 1)
	_preview.draw_string(load(_fontData), Vector2.ZERO, text, HORIZONTAL_ALIGNMENT_LEFT)

func _drawAtlas() -> void:
	_atlas.draw_rect(Rect2(Vector2.ZERO, size), Color(0.5, 0.5, 0.5, 0.5), false)
	for i in _characters.keys():
		var c = _characters[i]
		var r := Rect2(c["x"], c["y"], c["width"], c["height"])
		_atlas.draw_rect(r, Color(0, 1, 0, 0.5), false)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			scale /= Vector2(_zoomFactor, _zoomFactor)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			scale *= Vector2(_zoomFactor, _zoomFactor)
	elif event is InputEventMouseMotion:
		if event.button_mask & MOUSE_BUTTON_MASK_MIDDLE:
			position += event.relative
