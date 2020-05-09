extends Node2D

onready var _sprite := $Sprite

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(_delta) -> void:
	global_position = get_global_mouse_position()
	match Input.get_current_cursor_shape():
		Input.CURSOR_ARROW:
			if Input.is_action_just_pressed("mb_left"):
				_sprite.play("ArrowClick")
			else:
				_sprite.play("Arrow")
		Input.CURSOR_IBEAM:
			_sprite.play("Caret")
		Input.CURSOR_POINTING_HAND:
			if Input.is_action_just_pressed("mb_left"):
				_sprite.play("PointClick")
			else:
				_sprite.play("Point")
		Input.CURSOR_CROSS:
			_sprite.play("Cross")
		Input.CURSOR_WAIT:
			_sprite.play("Wait")
		Input.CURSOR_BUSY:
			_sprite.play("Busy")
		Input.CURSOR_DRAG:
			_sprite.play("Drag")
		Input.CURSOR_CAN_DROP:
			_sprite.play("Arrow")
		Input.CURSOR_FORBIDDEN:
			_sprite.play("Drop")
		Input.CURSOR_VSIZE:
			_sprite.play("SizeV")
		Input.CURSOR_HSIZE:
			_sprite.play("SizeH")
		Input.CURSOR_BDIAGSIZE:
			_sprite.play("SizeDiagBack")
		Input.CURSOR_FDIAGSIZE:
			_sprite.play("SizeDiagFore")
		Input.CURSOR_MOVE:
			_sprite.play("Move")
		Input.CURSOR_VSPLIT:
			_sprite.play("SplitV")
		Input.CURSOR_HSPLIT:
			_sprite.play("SplitH")
		Input.CURSOR_HELP:
			_sprite.play("Help")
