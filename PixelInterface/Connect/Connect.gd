extends Control

export var time = 0.333

var connectedColor = Color(0.5, 0.75, 0.5)
var disconnectedColor = Color(0.75, 0.5, 0.5)

onready var interface = $Container/Viewport/Interface
onready var dialog = $Container/Viewport/Dialog
onready var http = $HTTPRequest
onready var tween = $Tween
onready var clickAudio = $Click
onready var errorAudio = $Error

onready var status = $Container/Viewport/Interface/Status/Panel/Status

onready var signInEmail    = $Container/Viewport/Interface/SignIn/Center/Panel/VBox/Panel/VBox/Email
onready var signInPassword = $Container/Viewport/Interface/SignIn/Center/Panel/VBox/Panel/VBox/Password
onready var signInSignIn   = $Container/Viewport/Interface/SignIn/Center/Panel/VBox/SignIn
onready var signInSignUp   = $Container/Viewport/Interface/SignIn/Center/Panel/VBox/HBox/SignUp
onready var signInReset    = $Container/Viewport/Interface/SignIn/Center/Panel/VBox/HBox/Reset
onready var signInClose    = $Container/Viewport/Interface/SignIn/Center/Panel/Close/Close

onready var signUpEmail    = $Container/Viewport/Interface/SignUp/Center/Panel/VBox/Panel/VBox/Email
onready var signUpPassword = $Container/Viewport/Interface/SignUp/Center/Panel/VBox/Panel/VBox/Password
onready var signUpConfirm  = $Container/Viewport/Interface/SignUp/Center/Panel/VBox/Panel/VBox/Confirm
onready var signUpSignUp   = $Container/Viewport/Interface/SignUp/Center/Panel/VBox/SignUp
onready var signUpClose    = $Container/Viewport/Interface/SignUp/Center/Panel/Close/Close

onready var resetEmail = $Container/Viewport/Interface/Reset/Center/Panel/VBox/Panel/Email
onready var resetReset = $Container/Viewport/Interface/Reset/Center/Panel/VBox/Reset
onready var resetClose = $Container/Viewport/Interface/Reset/Center/Panel/Close/Close

onready var accountEmail          = $Container/Viewport/Interface/Account/Center/Panel/VBox/Panel/Email
onready var accountSignOut        = $Container/Viewport/Interface/Account/Center/Panel/VBox/SignOut
onready var accountChangeEmail    = $Container/Viewport/Interface/Account/Center/Panel/VBox/HBox/Email
onready var accountChangePassword = $Container/Viewport/Interface/Account/Center/Panel/VBox/HBox/Password
onready var accountClose          = $Container/Viewport/Interface/Account/Center/Panel/Close/Close

onready var emailPassword = $Container/Viewport/Interface/Email/Center/Panel/VBox/Panel/VBox/Password
onready var emailEmail    = $Container/Viewport/Interface/Email/Center/Panel/VBox/Panel/VBox/Email
onready var emailConfirm  = $Container/Viewport/Interface/Email/Center/Panel/VBox/Panel/VBox/Confirm
onready var emailChange   = $Container/Viewport/Interface/Email/Center/Panel/VBox/Change
onready var emailClose    = $Container/Viewport/Interface/Email/Center/Panel/Close/Close

onready var passwordOld     = $Container/Viewport/Interface/Password/Center/Panel/VBox/Panel/VBox/Old
onready var passwordNew     = $Container/Viewport/Interface/Password/Center/Panel/VBox/Panel/VBox/New
onready var passwordConfirm = $Container/Viewport/Interface/Password/Center/Panel/VBox/Panel/VBox/Confirm
onready var passwordChange  = $Container/Viewport/Interface/Password/Center/Panel/VBox/Change
onready var passwordClose   = $Container/Viewport/Interface/Password/Center/Panel/Close/Close

onready var messageTitle = $Container/Viewport/Dialog/Message/Center/Panel/VBox/Title
onready var messageText  = $Container/Viewport/Dialog/Message/Center/Panel/VBox/Panel/Text
onready var messageClose = $Container/Viewport/Dialog/Message/Center/Panel/Close/Close

const messagePosition = Vector2(3000, 0)

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
	Utility.ok(signInSignUp.connect("pressed", self, "_on_SignInSignUo_pressed"))
	Utility.ok(signInReset.connect("pressed", self, "_on_SignInReset_pressed"))
	Utility.ok(signInClose.connect("pressed", self, "_on_Close_pressed"))
	
	Utility.ok(signUpSignUp.connect("pressed", self, "_on_SignUp_pressed"))
	Utility.ok(signUpClose.connect("pressed", self, "_on_CloseSignIn_pressed"))
	
	Utility.ok(resetClose.connect("pressed", self, "_on_CloseSignIn_pressed"))
	
	Utility.ok(accountClose.connect("pressed", self, "_on_Close_pressed"))
	Utility.ok(accountSignOut.connect("pressed", self, "_on_SignOut_pressed"))
	
	Utility.ok(emailClose.connect("pressed", self, "_on_CloseAccount_pressed"))
	Utility.ok(passwordClose.connect("pressed", self, "_on_CloseAccount_pressed"))
	Utility.ok(messageClose.connect("pressed", self, "_springErrorBack"))

	Utility.ok(Firebase.connect("signedIn", self, "_onSignedIn"))
	Utility.ok(Firebase.connect("signedUp", self, "_onSignedUp"))
	Utility.ok(Firebase.connect("signedOut", self, "_onSignedOut"))
	_loadEmail()
	_updateStatus()
	regex.compile(pattern)

func _spring(p = Vector2.ZERO, c = interface):
	var current = c.get_position()
	if  not current.is_equal_approx(p):
		if tween.interpolate_property(c, "rect_position", current, p, time, Tween.TRANS_ELASTIC, Tween.EASE_OUT):
			if not tween.start():
				print("error")

func _springSignIn():
	_spring(signInPosition)

func _springSignUp():
	_spring(signUpPosition)

func _springReset():
	_spring(resetPosition)

func _springAccount():
	_spring(accountPosition)

func _springEmail():
	_spring(emailPosition)

func _springPassword():
	_spring(passwordPosition)

func _springMessage():
	_spring(messagePosition, dialog)

func _springMessageBack():
	clickAudio.play()
	_spring(Vector2.ZERO, dialog)

func _showError(title, text):
	errorAudio.play()
	messageTitle.text = title
	messageText.text = text
	_springMessage()

func _on_Status_pressed():
	clickAudio.play()
	if not Firebase.authenticated():
		_springSignIn()
	else:
		_springAccount()

func _updateStatus():
	if Firebase.authenticated():
		status.modulate = connectedColor
	else:
		status.modulate = disconnectedColor

func _on_SignIn_pressed():
	clickAudio.play()
	var email = signInEmail.text
	var password = signInPassword.text
	_errorClear([signInEmail, signInPassword])
	if not _validEmail(email):
		_errorSet(signInEmail)
		return
	if not _validPassword(password):
		_errorSet(signInPassword)
		return
	if email.empty() or password.empty():
		_showError("Error", "Please enter an email and password.")
		return
	_disableInput(signInSignIn)
	Firebase.signIn(http, email, password)
	_saveEmail()

func _on_SignInSignUo_pressed():
	clickAudio.play()
	_springSignUp()

func _on_SignInReset_pressed():
	clickAudio.play()
	_springReset()

func _on_Close_pressed():
	clickAudio.play()
	_spring()

func _on_CloseSignIn_pressed():
	clickAudio.play()
	_springSignIn()

func _on_CloseAccount_pressed():
	clickAudio.play()
	_springAccount()

func _onSignedIn(response):
	if response[1] == 200:
		signInPassword.text = ""
		_updateStatus()
		_spring()
	else:
		var test = JSON.parse(response[3].get_string_from_ascii()).result as Dictionary
		_showError("Error", test.error.message.capitalize())
	_enableInput(signInSignIn)

func _on_SignUp_pressed():
	clickAudio.play()
	var email = signUpEmail.text
	var password = signUpPassword.text
	var confirm = signUpConfirm.text
	if email.empty() or password.empty():
		_showError("Error", "Please enter an email and password.")
		return
	if password != confirm:
		_showError("Error", "Passwords must match.")
		return
	Firebase.signUp(http, email, password)

func _onSignedUp(response):
	if response[1] == 200:
		_updateStatus()
		_spring()
	else:
		var test = JSON.parse(response[3].get_string_from_ascii()).result as Dictionary
		_showError("Error", test.error.message.capitalize())

func _on_SignOut_pressed():
	clickAudio.play()
	Firebase.signOut()

func _onSignedOut():
	_updateStatus()
	_spring()

func _saveEmail():
	if (not signInEmail.text.empty()):
		signUpEmail.text = signInEmail.text
		resetEmail.text = signInEmail.text
		f.open(emailPath, File.WRITE)
		f.store_string(signInEmail.text)
		f.close()

func _loadEmail():
	if f.file_exists(emailPath):
		f.open(emailPath, File.READ)
		signInEmail.text = f.get_as_text()
		f.close()

func _validEmail(text: String) -> bool:
	return regex.search(text)

func _validPassword(text: String) -> bool:
	return text.length() > 2

func _errorClear(controls: Array):
	for i in range(controls.size()):
		controls[i].modulate = Color.white

func _errorSet(control: LineEdit):
	errorAudio.play()
	control.modulate = disconnectedColor

func _thinking(control: Control, enable: bool):
	if enable:
		tween.repeat = true;
		tween.interpolate_property(control, "rect_scale.x", 1, 1.5, 1, Tween.TRANS_CIRC, Tween.EASE_IN_OUT)
		tween.interpolate_property(control, "rect_scale.y", 1.5, 1, 1, Tween.TRANS_CIRC, Tween.EASE_IN_OUT)
		tween.start()
	else:
		tween.stop(control, "rect_scale.x");
		tween.stop(control, "rect_scale.y");
		tween.repeat = false;

func _disableInput(control: Button):
	_thinking(control, true)
	control.disabled = true

func _enableInput(control: Button):
	_thinking(control, false)
	control.disabled = false;
