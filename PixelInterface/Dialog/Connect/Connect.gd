extends Control

export var time = 0.333

onready var interface = $ViewportContainer/Viewport/Interface
onready var error = $ViewportContainer/Viewport/Error
onready var errorError = $ViewportContainer/Viewport/Error/Error
onready var http = $HTTPRequest
onready var tween = $Tween

onready var errorTitle = $ViewportContainer/Viewport/Error/Error/Panel/Label
onready var errorText = $ViewportContainer/Viewport/Error/Error/Panel/Panel/Label
onready var errorClose = $ViewportContainer/Viewport/Error/Error/Panel/Close/Close

onready var status = $ViewportContainer/Viewport/Interface/Status/Panel/Status
onready var signInSignIn = $ViewportContainer/Viewport/Interface/SignIn/Panel/VBoxContainer/Buttons/SignIn
onready var signInSignUp = $ViewportContainer/Viewport/Interface/SignIn/Panel/VBoxContainer/Buttons/HBoxContainer/SignUp
onready var signInReset = $ViewportContainer/Viewport/Interface/SignIn/Panel/VBoxContainer/Buttons/HBoxContainer/Reset
onready var signInClose = $ViewportContainer/Viewport/Interface/SignIn/Panel/Close/Close
onready var signUpClose = $ViewportContainer/Viewport/Interface/SignUp/Panel/Close/Close
onready var resetClose = $ViewportContainer/Viewport/Interface/Reset/Panel/Close/Close
onready var accountClose = $ViewportContainer/Viewport/Interface/Account/Panel/Close/Close
onready var emailClose = $ViewportContainer/Viewport/Interface/Email/Panel/Close/Close
onready var passwordClose = $ViewportContainer/Viewport/Interface/Password/Panel/Close/Close

const errorPosition = Vector2(3000, 0)

const signInPosition = Vector2(0, 3000)
const signUpPosition = Vector2(3000, 3000)
const resetPosition = Vector2(-3000, 3000)

const accountPosition = Vector2(0, -3000)
const emailPosition = Vector2(3000, -3000)
const passwordPosition = Vector2(-3000, -3000)

func _ready():
	Utility.ok(status.connect("pressed", self, "_on_Status_pressed"))
	Utility.ok(signInSignUp.connect("pressed", self, "springSignUp"))
	Utility.ok(signInReset.connect("pressed", self, "springReset"))
	Utility.ok(signInClose.connect("pressed", self, "spring"))
	Utility.ok(signUpClose.connect("pressed", self, "springSignIn"))
	Utility.ok(resetClose.connect("pressed", self, "springSignIn"))
	Utility.ok(accountClose.connect("pressed", self, "spring"))
	Utility.ok(emailClose.connect("pressed", self, "springAccount"))
	Utility.ok(passwordClose.connect("pressed", self, "springAccount"))
	Utility.ok(errorClose.connect("pressed", self, "springErrorBack"))

func spring(p = Vector2.ZERO, c = interface):
	var current = c.get_position()
	if  not current.is_equal_approx(p):
		if tween.interpolate_property(c, "rect_position", current, p, time, Tween.TRANS_ELASTIC, Tween.EASE_OUT):
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
	Firebase.api(http)
	if Firebase.authenticated():
		springSignIn()
	else:
		showError("Connect", "Welcome back")

func showError(title, text):
	errorTitle.text = title
	errorText.text = text
	springError()
