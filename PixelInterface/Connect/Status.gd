extends Panel

const _time = 0.333
const _trans = Tween.TRANS_EXPO
const _ease = Tween.EASE_OUT

onready var _tip = $Margin
onready var _tween = $Tween

func _ready():
	assert(connect("mouse_entered", self, "mouseEntered") == OK)
	assert(connect("mouse_exited", self, "mouseExited") == OK)

func mouseEntered():
	_tween.stop_all()
	_tween.interpolate_property(_tip, "rect_rotation", null, 0, _time, _trans, _ease)
	_tween.interpolate_property(_tip, "modulate", null, Color(1, 1, 1, 0.75), _time, _trans, _ease)
	_tween.start()

func mouseExited():
	_tween.stop_all()
	_tween.interpolate_property(_tip, "rect_rotation", null, -90, _time, _trans, _ease)
	_tween.interpolate_property(_tip, "modulate", null, Color(0, 0, 0, 0), _time, _trans, _ease)
	_tween.start()
