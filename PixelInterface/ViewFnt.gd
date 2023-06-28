## Display BMFont file.
@tool
extends Control

@onready var _preview := $TexturePreview
@onready var _atlas := $TextureAtlas

@export_file("*.fnt") var _font_data: String
var _font: Resource
var _characters: Dictionary
var _image_path: String
var _size: Vector2i
var _line_height: int
var _base: int
var _points: Array
const _zoom_factor := Vector2(1.1, 1.1)
const _width := 1000

func _ready() -> void:
	if _font_data.is_empty():
		printerr("ViewFnt: Set font file in inspector.")
		return
	_parseFont()
	var offset = _line_height - _base
	var half := int(_line_height / 2.0)
	var base_1 := Vector2(0, offset - 0.5)
	var base_2 := Vector2(_width, offset - 0.5)
	var top1 := Vector2(0, -half - offset - 0.5)
	var top2 := Vector2(_width, -half - offset - 0.5)
	var bottom_1 := Vector2(0, offset + offset + 0.5)
	var bottom_2 := Vector2(_width, offset + offset + 0.5)
	_points = [base_1, base_2, top1, top2, bottom_1, bottom_2]
	_atlas.texture = load(_font_data.get_base_dir() + "/" + _image_path)
	_atlas.scale = Vector2(4, 4)
	_atlas.size = _size
	_atlas.connect("draw", _drawAtlas)
	_font = load(_font_data)
	_preview.connect("draw", _drawPreview)

func _parseFont() -> void:
	var file = FileAccess.open(_font_data, FileAccess.READ)
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
	var file = FileAccess.open(_font_data, FileAccess.READ)
	if not file: return
	while !file.eof_reached():
		var line = file.get_line()
		if line.begins_with("page id=0"):
			var info := parseLine(line)
			_image_path = info["file"].replace("\"", "")
		if line.begins_with("common"):
			var info := parseLine(line)
			_line_height = info["lineHeight"]
			_base = info["base"]
			_size = Vector2i(info["scaleW"], info["scaleH"])

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

func _drawAtlas() -> void:
	_atlas.draw_rect(Rect2(Vector2.ZERO, _atlas.size), Color(0.5, 0.5, 0.5, 0.5), false, 2)
	for i in _characters.keys():
		var c = _characters[i]
		var r := Rect2(c["x"], c["y"], c["width"], c["height"])
		_atlas.draw_rect(r, Color(0, 1, 0, 0.5), false)

func _drawPreview() -> void:
	_preview.draw_line(_points[0], _points[1], Color(1, 0, 0, 0.5), 1) # base
	_preview.draw_line(_points[2], _points[3], Color(0, 0, 1, 0.5), 1) # lineHeight
	_preview.draw_line(_points[4], _points[5], Color(0, 0, 1, 0.5), 1) # lineHeight
	var text := "! !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"
	_preview.draw_string(_font, Vector2.ZERO, text, HORIZONTAL_ALIGNMENT_LEFT)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			scale /= _zoom_factor
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			scale *= _zoom_factor
	elif event is InputEventMouseMotion:
		if event.button_mask & MOUSE_BUTTON_MASK_MIDDLE:
			position += event.relative
