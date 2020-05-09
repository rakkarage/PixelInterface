extends Panel

const _time = .333
const _trans = Tween.TRANS_EXPO
const _ease = Tween.EASE_OUT

func _ready():
	Utility.ok(connect("mouse_entered", self, "mouseEntered"))
	Utility.ok(connect("mouse_exited", self, "mouseExited"))

func mouseEntered():
	$Tween.stop_all()
	$Tween.interpolate_property($Margin, "rect_rotation", null, 0, _time, _trans, _ease)
	$Tween.interpolate_property($Margin, "modulate", null, Color(1, 1, 1, 0.75), _time, _trans, _ease)
	$Tween.start()

func mouseExited():
	$Tween.stop_all()
	$Tween.interpolate_property($Margin, "rect_rotation", null, -90, _time, _trans, _ease)
	$Tween.interpolate_property($Margin, "modulate", null, Color(0, 0, 0, 0), _time, _trans, _ease)
	$Tween.start()
