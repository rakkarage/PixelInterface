extends Node2D

var wait := false
var busy := false

onready var _sprite := $Sprite

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _physics_process(_delta) -> void:
	global_position = get_global_mouse_position()
	_sprite.centered = false
	if busy:
		_sprite.centered = true
		_sprite.play("Busy")
	elif wait:
		_sprite.play("Wait")
	else:
		match Input.get_current_cursor_shape():
			Input.CURSOR_ARROW:
				if Input.is_mouse_button_pressed(BUTTON_LEFT) or Input.is_mouse_button_pressed(BUTTON_RIGHT):
					_sprite.play("ArrowClick")
				else:
					_sprite.play("Arrow")
			Input.CURSOR_IBEAM:
				_sprite.centered = true
				_sprite.play("Caret")
			Input.CURSOR_POINTING_HAND:
				if Input.is_mouse_button_pressed(BUTTON_LEFT) or Input.is_mouse_button_pressed(BUTTON_RIGHT):
					_sprite.play("PointClick")
				else:
					_sprite.play("Point")
			Input.CURSOR_CROSS:
				_sprite.centered = true
				_sprite.play("Cross")
			Input.CURSOR_WAIT:
				_sprite.play("Wait")
			Input.CURSOR_BUSY:
				_sprite.centered = true
				_sprite.play("Busy")
			Input.CURSOR_DRAG:
				_sprite.play("Drag")
			Input.CURSOR_CAN_DROP:
				_sprite.play("Arrow")
			Input.CURSOR_FORBIDDEN:
				_sprite.centered = true
				_sprite.play("Drop")
			Input.CURSOR_VSIZE:
				_sprite.centered = true
				_sprite.play("SizeV")
			Input.CURSOR_HSIZE:
				_sprite.centered = true
				_sprite.play("SizeH")
			Input.CURSOR_BDIAGSIZE:
				_sprite.centered = true
				_sprite.play("SizeDiagBack")
			Input.CURSOR_FDIAGSIZE:
				_sprite.centered = true
				_sprite.play("SizeDiagFore")
			Input.CURSOR_MOVE:
				_sprite.centered = true
				_sprite.play("Move")
			Input.CURSOR_VSPLIT:
				_sprite.centered = true
				_sprite.play("SplitV")
			Input.CURSOR_HSPLIT:
				_sprite.centered = true
				_sprite.play("SplitH")
			Input.CURSOR_HELP:
				_sprite.centered = true
				_sprite.play("Help")
