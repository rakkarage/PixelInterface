extends Control

onready var interface : Control = $ViewportContainer/Viewport/Interface
onready var error : Control = $ViewportContainer/Viewport/Error
onready var tween : Tween = $Tween

const errorPosition = Vector2(-3000, 0)
const signInPosition = Vector2(0, 3000)
const signUpPosition = Vector2(-3000, 3000)
const resetPosition = Vector2(3000, 3000)
const accountPosition = Vector2(0, -3000)
const emailPosition = Vector2(-3000, -3000)
const passwordPosition = Vector2(3000, -3000)

export var time = 1.0

func Spring(p := Vector2.ZERO, c : Control = interface):
	var current = c.get_position()
	if !current.is_equal_approx(p):
		if !tween.interpolate_property(interface, "rect_position", current, p, time, Tween.TRANS_BACK, Tween.EASE_OUT):
			if !tween.start():
				print("errror")

func SpringSignIn():
	Spring(signInPosition)

func SpringSignUp():
	Spring(signUpPosition)

func Reset():
	Spring(resetPosition)

func SpringAccount():
	Spring(accountPosition)

func SpringEmail():
	Spring(emailPosition)

func SpringPassword():
	Spring(passwordPosition)

func SpringError():
	Spring(errorPosition, error)

func SpringErrorBack():
	Spring(Vector2.ZERO, error)
	
func _on_Button_pressed():
	Spring(signInPosition)
