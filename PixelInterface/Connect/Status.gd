extends Panel

const _time = 0.333
const _trans = Tween.TRANS_EXPO
const _ease = Tween.EASE_OUT

@onready var _tip = $Margin

func _ready():
	connect("mouse_entered", _mouseEntered)
	connect("mouse_exited", _mouseExited)

func _mouseEntered():
	var tween := create_tween()
	tween.set_trans(_trans).set_ease(_ease)
	tween.tween_property(_tip, "rotation", 0, _time)
	tween.parallel().tween_property(_tip, "modulate", Color(1, 1, 1, 0.75), _time)

func _mouseExited():
	var tween := create_tween()
	tween.set_trans(_trans).set_ease(_ease)
	tween.tween_property(_tip, "rotation", -90, _time)
	tween.parallel().tween_property(_tip, "modulate", Color(0, 0, 0, 0), _time)
