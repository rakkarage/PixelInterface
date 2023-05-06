extends Panel

const _time = 0.333
const _trans = Tween.TRANS_EXPO
const _ease = Tween.EASE_OUT

@onready var _tip = $Margin
var _tween: Tween

func _ready():
	_tween = get_tree().create_tween()
	connect("mouse_entered", Callable(self, "mouseEntered"))
	connect("mouse_exited", Callable(self, "mouseExited"))

func mouseEntered():
	_tween.stop_all()
	_tween.interpolate_property(_tip, "rotation", null, 0, _time, _trans, _ease)
	_tween.interpolate_property(_tip, "modulate", null, Color(1, 1, 1, 0.75), _time, _trans, _ease)
	_tween.start()

func mouseExited():
	_tween.stop_all()
	_tween.interpolate_property(_tip, "rotation", null, -90, _time, _trans, _ease)
	_tween.interpolate_property(_tip, "modulate", null, Color(0, 0, 0, 0), _time, _trans, _ease)
	_tween.start()
