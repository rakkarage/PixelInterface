extends Control
class_name Connect

export var time = 0.333

onready var interface = $ViewportContainer/Viewport/Interface
onready var error = $ViewportContainer/Viewport/Error
onready var tween = $Tween
onready var status = $ViewportContainer/Viewport/Interface/Status/Panel/Status
onready var signInSignIn = $ViewportContainer/Viewport/Interface/SignIn/Panel/VBoxContainer/Buttons/SignIn
onready var signInSignUp = $ViewportContainer/Viewport/Interface/SignIn/Panel/VBoxContainer/Buttons/HBoxContainer/SignUp
onready var signInReset = $ViewportContainer/Viewport/Interface/SignIn/Panel/VBoxContainer/Buttons/HBoxContainer/Reset
onready var signInClose = $ViewportContainer/Viewport/Interface/SignIn/Panel/Close/Close
onready var signUpClose = $ViewportContainer/Viewport/Interface/SignUp/Panel/Close/Close
onready var resetClose = $ViewportContainer/Viewport/Interface/Reset/Panel/Close/Close

const errorPosition = Vector2(-3000, 0)
const signInPosition = Vector2(0, 3000)
const signUpPosition = Vector2(-3000, 3000)
const resetPosition = Vector2(3000, 3000)
const accountPosition = Vector2(0, -3000)
const emailPosition = Vector2(-3000, -3000)
const passwordPosition = Vector2(3000, -3000)

func _ready():
	handleError(status.connect("pressed", self, "_on_Status_pressed"))
	handleError(signInSignUp.connect("pressed", self, "springSignUp"))
	handleError(signInReset.connect("pressed", self, "springReset"))
	handleError(signInClose.connect("pressed", self, "spring"))
	handleError(signUpClose.connect("pressed", self, "springSignIn"))
	handleError(resetClose.connect("pressed", self, "springSignIn"))

func handleError(e):
	if e != OK:
		print("error: " + str(e))

func spring(p = Vector2.ZERO, c = interface):
	var current = c.get_position()
	if  not current.is_equal_approx(p):
		if tween.interpolate_property(interface, "rect_position", current, p, time, Tween.TRANS_ELASTIC, Tween.EASE_OUT):
			if not tween.start():
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
