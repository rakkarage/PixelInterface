extends Panel

const _time = 0.333
const _trans = Tween.TRANS_EXPO
const _ease = Tween.EASE_IN

func _ready():
	Utility.ok(connect("mouse_entered", self, "mouseEntered"))
	Utility.ok(connect("mouse_exited", self, "mouseExited"))
	Utility.ok($Panel.connect("mouse_entered", self, "mouseEntered"))
	Utility.ok($Panel.connect("mouse_exited", self, "mouseExited"))

func mouseEntered():
	if Firebase.authenticated():
		$Tween.stop($Panel, "rect_rotation")
		$Tween.interpolate_property($Panel, "rect_rotation", null, 0, _time, _trans, _ease)
		$Tween.stop($Panel, "modulate")
		$Tween.interpolate_property($Panel, "modulate", null, Color.white, _time, _trans, _ease)
		$Tween.start()

func mouseExited():
	$Tween.stop($Panel, "rect_rotation")
	$Tween.interpolate_property($Panel, "rect_rotation", null, -90, _time, _trans, _ease)
	$Tween.stop($Panel, "modulate")
	$Tween.interpolate_property($Panel, "modulate", null, Color(0, 0, 0, 0), _time, _trans, _ease)
	$Tween.start()
