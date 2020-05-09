extends Node2D

onready var _sprite = $Sprite

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(delta):
	var p = get_global_mouse_position()
	if Input.is_action_pressed("mb_left"):
		_sprite.play("Click")
