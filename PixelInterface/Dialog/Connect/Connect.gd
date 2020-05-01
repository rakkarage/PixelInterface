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

onready var signInEmail = $ViewportContainer/Viewport/Interface/SignIn/Panel/VBoxContainer/Panel/Input/HBoxContainer/Email/LineEdit
onready var signInPassword = $ViewportContainer/Viewport/Interface/SignIn/Panel/VBoxContainer/Panel/Input/HBoxContainer/Password/LineEdit
onready var signInSignIn = $ViewportContainer/Viewport/Interface/SignIn/Panel/VBoxContainer/Buttons/SignIn
onready var signInSignUp = $ViewportContainer/Viewport/Interface/SignIn/Panel/VBoxContainer/Buttons/HBoxContainer/SignUp
onready var signInReset = $ViewportContainer/Viewport/Interface/SignIn/Panel/VBoxContainer/Buttons/HBoxContainer/Reset
onready var signInClose = $ViewportContainer/Viewport/Interface/SignIn/Panel/Close/Close

onready var signUpEmail = $ViewportContainer/Viewport/Interface/SignUp/Panel/VBoxContainer/Panel/Input/HBoxContainer/Email/LineEdit
onready var signUpPassword = $ViewportContainer/Viewport/Interface/SignUp/Panel/VBoxContainer/Panel/Input/HBoxContainer/Password/LineEdit
onready var signUpConfirm = $ViewportContainer/Viewport/Interface/SignUp/Panel/VBoxContainer/Panel/Input/HBoxContainer/Confirm/LineEdit
onready var signUpSignUp = $ViewportContainer/Viewport/Interface/SignUp/Panel/SignUp
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
	Utility.ok(signInSignIn.connect("pressed", self, "_on_SignIn_pressed"))
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

func showError(title, text):
	errorTitle.text = title
	errorText.text = text
	springError()

func _on_Status_pressed():
	Firebase.api(http)
	if not Firebase.authenticated():
		springSignIn()

func _on_SignIn_pressed():
	var email = signInEmail.text;
	var password = signInPassword.text;
	if email.empty() or password.empty():
		showError("Error", "Please enter an email and password.")
		return
	Firebase.signIn(http, email, password)

func _on_SignUp_pressed():
	var email = signUpEmail.text;
	var password = signUpPassword.text;
	var confirm = signUpConfirm.text;
	if email.empty() or password.empty():
		showError("Error", "Please enter an email and password.")
		return
	if password != confirm:
		showError("Error", "Passwords must match.")
		return
	Firebase.signUp(http, email, password)
