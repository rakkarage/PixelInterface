extends Control

export var time = 0.333

var connectedColor = Color(0.5, 0.75, 0.5)
var disconnectedColor = Color(0.75, 0.5, 0.5)

onready var interface = $ViewportContainer/Viewport/Interface
onready var error = $ViewportContainer/Viewport/Error
onready var http = $HTTPRequest
onready var tween = $Tween
onready var clickAudio = $Click
onready var errorAudio = $Error

onready var errorTitle = $ViewportContainer/Viewport/Error/Error/Panel/Label
onready var errorText = $ViewportContainer/Viewport/Error/Error/Panel/Panel/Label
onready var errorClose = $ViewportContainer/Viewport/Error/Error/Panel/Close/Close

onready var status = $ViewportContainer/Viewport/Interface/Status/Panel/Status

onready var signInEmail = $ViewportContainer/Viewport/Interface/SignIn/Panel/VBoxContainer/Panel/Input/Email/LineEdit
onready var signInPassword = $ViewportContainer/Viewport/Interface/SignIn/Panel/VBoxContainer/Panel/Input/Password/LineEdit
onready var signInSignIn = $ViewportContainer/Viewport/Interface/SignIn/Panel/VBoxContainer/Buttons/SignIn
onready var signInSignUp = $ViewportContainer/Viewport/Interface/SignIn/Panel/VBoxContainer/Buttons/HBoxContainer/SignUp
onready var signInReset = $ViewportContainer/Viewport/Interface/SignIn/Panel/VBoxContainer/Buttons/HBoxContainer/Reset
onready var signInClose = $ViewportContainer/Viewport/Interface/SignIn/Panel/Close/Close

onready var signUpEmail = $ViewportContainer/Viewport/Interface/SignUp/Panel/VBoxContainer/Panel/Input/Email/LineEdit
onready var signUpPassword = $ViewportContainer/Viewport/Interface/SignUp/Panel/VBoxContainer/Panel/Input/Password/LineEdit
onready var signUpConfirm = $ViewportContainer/Viewport/Interface/SignUp/Panel/VBoxContainer/Panel/Input/Confirm/LineEdit
onready var signUpSignUp = $ViewportContainer/Viewport/Interface/SignUp/Panel/SignUp
onready var signUpClose = $ViewportContainer/Viewport/Interface/SignUp/Panel/Close/Close

onready var resetEmail = $ViewportContainer/Viewport/Interface/Reset/Panel/Panel/HBoxContainer/LineEdit
onready var resetReset = $ViewportContainer/Viewport/Interface/Reset/Panel/Reset
onready var resetClose = $ViewportContainer/Viewport/Interface/Reset/Panel/Close/Close

onready var accountSignOut = $ViewportContainer/Viewport/Interface/Account/Panel/VBoxContainer/Buttons/SignOut
onready var accountEmail = $ViewportContainer/Viewport/Interface/Account/Panel/VBoxContainer/Buttons/HBoxContainer/Email
onready var accountPassword = $ViewportContainer/Viewport/Interface/Account/Panel/VBoxContainer/Buttons/HBoxContainer/Password
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

var f = File.new()
const emailPath = "user://email.txt";
var regex = RegEx.new()
const pattern = "(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+$)"

func _ready():
	Utility.ok(status.connect("pressed", self, "_on_Status_pressed"))
	
	Utility.ok(signInSignIn.connect("pressed", self, "_on_SignIn_pressed"))
	Utility.ok(signInSignUp.connect("pressed", self, "springSignUp"))
	Utility.ok(signInReset.connect("pressed", self, "springReset"))
	Utility.ok(signInClose.connect("pressed", self, "spring"))
	
	Utility.ok(signUpSignUp.connect("pressed", self, "_on_SignUp_pressed"))
	Utility.ok(signUpClose.connect("pressed", self, "springSignIn"))
	
	Utility.ok(resetClose.connect("pressed", self, "springSignIn"))
	
	Utility.ok(accountClose.connect("pressed", self, "spring"))
	Utility.ok(accountSignOut.connect("pressed", self, "_on_SignOut_pressed"))
	
	Utility.ok(emailClose.connect("pressed", self, "springAccount"))
	Utility.ok(passwordClose.connect("pressed", self, "springAccount"))
	Utility.ok(errorClose.connect("pressed", self, "springErrorBack"))

	Utility.ok(Firebase.connect("signedIn", self, "OnSignedIn"))
	Utility.ok(Firebase.connect("signedUp", self, "OnSignedUp"))
	Utility.ok(Firebase.connect("signedOut", self, "OnSignedOut"))
	loadEmail()
	updateStatus()
	regex.compile(pattern)

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
	errorAudio.play()
	errorTitle.text = title
	errorText.text = text
	springError()

func _on_Status_pressed():
	clickAudio.play()
	if not Firebase.authenticated():
		springSignIn()
	else:
		springAccount()

func updateStatus():
	if Firebase.authenticated():
		status.modulate = connectedColor
	else:
		status.modulate = disconnectedColor

func _on_SignIn_pressed():
	clickAudio.play()
	var email = signInEmail.text
	var password = signInPassword.text
	errorClear([signInEmail, signInPassword])
	if not validEmail(email):
		errorSet(signInEmail)
		return
	if not validPassword(password):
		errorSet(signInPassword)
		return
	if email.empty() or password.empty():
		showError("Error", "Please enter an email and password.")
		return
	disableInput(signInSignIn)
	Firebase.signIn(http, email, password)
	saveEmail()

func OnSignedIn(response):
	if response[1] == 200:
		signInPassword.text = ""
		updateStatus()
		spring()
	else:
		var test = JSON.parse(response[3].get_string_from_ascii()).result as Dictionary
		showError("Error", test.error.message.capitalize())
	enableInput(signInSignIn)

func _on_SignUp_pressed():
	clickAudio.play()
	var email = signUpEmail.text
	var password = signUpPassword.text
	var confirm = signUpConfirm.text
	if email.empty() or password.empty():
		showError("Error", "Please enter an email and password.")
		return
	if password != confirm:
		showError("Error", "Passwords must match.")
		return
	Firebase.signUp(http, email, password)

func OnSignedUp(response):
	if response[1] == 200:
		updateStatus()
		spring()
	else:
		var test = JSON.parse(response[3].get_string_from_ascii()).result as Dictionary
		showError("Error", test.error.message.capitalize())

func _on_SignOut_pressed():
	Firebase.signOut()

func OnSignedOut():
	updateStatus()
	spring()

func saveEmail():
	if (not signInEmail.text.empty()):
		signUpEmail.text = signInEmail.text
		resetEmail.text = signInEmail.text
		f.open(emailPath, File.WRITE)
		f.store_string(signInEmail.text)
		f.close()

func loadEmail():
	if f.file_exists(emailPath):
		f.open(emailPath, File.READ)
		signInEmail.text = f.get_as_text()
		f.close()

func validEmail(text: String) -> bool:
	return regex.search(text)

func validPassword(text: String) -> bool:
	return text.length() > 2

func errorClear(controls: Array):
	for i in range(controls.size()):
		controls[i].modulate = Color.white

func errorSet(control: LineEdit):
	errorAudio.play()
	control.modulate = disconnectedColor

func disableInput(control: Button):
	control.disabled = true

func enableInput(control: Button):
	control.disabled = false;
