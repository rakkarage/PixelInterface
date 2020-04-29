extends Control
class_name Connect

export var time = 0.333

onready var interface : Control = $ViewportContainer/Viewport/Interface
onready var error : Control = $ViewportContainer/Viewport/Error
onready var tween : Tween = $Tween
onready var status  : Button = $ViewportContainer/Viewport/Interface/Status/Panel/Status
onready var signInClose  : Button = $ViewportContainer/Viewport/Interface/SignIn/Panel/Close/Close

const errorPosition = Vector2(-3000, 0)
const signInPosition = Vector2(0, 3000)
const signUpPosition = Vector2(-3000, 3000)
const resetPosition = Vector2(3000, 3000)
const accountPosition = Vector2(0, -3000)
const emailPosition = Vector2(-3000, -3000)
const passwordPosition = Vector2(3000, -3000)

func _ready():
	handleError(status.connect("pressed", self, "_on_Status_pressed"))
	handleError(signInClose.connect("pressed", self, "_on_Close_pressed"))

func handleError(e : int):
	if e != OK:
		print("error: " + str(e))

func spring(p := Vector2.ZERO, c : Control = interface):
	var current = c.get_position()
	if !current.is_equal_approx(p):
		if tween.interpolate_property(interface, "rect_position", current, p, time, Tween.TRANS_ELASTIC, Tween.EASE_OUT):
			if !tween.start():
				print("error")

func springSignIn():
	spring(signInPosition)

func springSignUp():
	spring(signUpPosition)

func springReset():
	spring(resetPosition)

func springAccount():
	spring(accountPosition)

func springEmail():
	spring(emailPosition)

func springPassword():
	spring(passwordPosition)

func springError():
	spring(errorPosition, error)

func springErrorBack():
	spring(Vector2.ZERO, error)

func _on_Status_pressed():
	springSignIn()

func _on_Close_pressed():
	spring()
