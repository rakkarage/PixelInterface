extends Panel

const _time = 0.333

func _ready():
	Utility.ok(connect("mouse_entered", self, "mouseEntered"))
	Utility.ok(connect("mouse_exited", self, "mouseExited"))
	Utility.ok($Panel.connect("mouse_entered", self, "mouseEntered"))
	Utility.ok($Panel.connect("mouse_exited", self, "mouseExited"))

func setEmail(email: String):
	$Panel/Email.text = email

func mouseEntered():
	if Firebase.authenticated():
		$Tween.stop($Panel, "rect_rotation");
		$Tween.interpolate_property($Panel, "rect_rotation", null, 0, _time, Tween.TRANS_EXPO, Tween.EASE_IN)
		$Tween.stop($Panel, "modulate");
		$Tween.interpolate_property($Panel, "modulate", null, Color.white, _time, Tween.TRANS_EXPO, Tween.EASE_IN)
		$Tween.start()

func mouseExited():
	$Tween.stop($Panel, "rect_rotation");
	$Tween.interpolate_property($Panel, "rect_rotation", null, -90, _time, Tween.TRANS_EXPO, Tween.EASE_IN)
	$Tween.stop($Panel, "modulate");
	$Tween.interpolate_property($Panel, "modulate", null, Color(0, 0, 0, 0), _time, Tween.TRANS_EXPO, Tween.EASE_IN)
	$Tween.start()
