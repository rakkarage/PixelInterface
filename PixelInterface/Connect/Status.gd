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
	tween.interpolate_property(_tip, "rotation", null, 0, _time, _trans, _ease)
	tween.parallel().interpolate_property(_tip, "modulate", null, Color(1, 1, 1, 0.75), _time, _trans, _ease)

func _mouseExited():
	var tween := create_tween()
	tween.interpolate_property(_tip, "rotation", null, -90, _time, _trans, _ease)
	tween.parallel().interpolate_property(_tip, "modulate", null, Color(0, 0, 0, 0), _time, _trans, _ease)
