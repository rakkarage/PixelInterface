extends Control

onready var _interface = $Container/Viewport/Interface

onready var _status = $Container/Viewport/Interface/Status/Panel/Status

onready var _signInEmail    = $Container/Viewport/Interface/SignIn/Center/Panel/VBox/Panel/VBox/Email
onready var _signInPassword = $Container/Viewport/Interface/SignIn/Center/Panel/VBox/Panel/VBox/Password
onready var _signInSignIn   = $Container/Viewport/Interface/SignIn/Center/Panel/VBox/SignIn
onready var _signInSignUp   = $Container/Viewport/Interface/SignIn/Center/Panel/VBox/HBox/SignUp
onready var _signInReset    = $Container/Viewport/Interface/SignIn/Center/Panel/VBox/HBox/Reset
onready var _signInClose    = $Container/Viewport/Interface/SignIn/Center/Panel/Close/Close

onready var _signUpEmail    = $Container/Viewport/Interface/SignUp/Center/Panel/VBox/Panel/VBox/Email
onready var _signUpPassword = $Container/Viewport/Interface/SignUp/Center/Panel/VBox/Panel/VBox/Password
onready var _signUpConfirm  = $Container/Viewport/Interface/SignUp/Center/Panel/VBox/Panel/VBox/Confirm
onready var _signUpSignUp   = $Container/Viewport/Interface/SignUp/Center/Panel/VBox/SignUp
onready var _signUpClose    = $Container/Viewport/Interface/SignUp/Center/Panel/Close/Close

onready var _resetEmail = $Container/Viewport/Interface/Reset/Center/Panel/VBox/Panel/Email
onready var _resetReset = $Container/Viewport/Interface/Reset/Center/Panel/VBox/Reset
onready var _resetClose = $Container/Viewport/Interface/Reset/Center/Panel/Close/Close

onready var _accountEmail          = $Container/Viewport/Interface/Account/Center/Panel/VBox/Panel/Email
onready var _accountSignOut        = $Container/Viewport/Interface/Account/Center/Panel/VBox/SignOut
onready var _accountChangeEmail    = $Container/Viewport/Interface/Account/Center/Panel/VBox/HBox/Email
onready var _accountChangePassword = $Container/Viewport/Interface/Account/Center/Panel/VBox/HBox/Password
onready var _accountClose          = $Container/Viewport/Interface/Account/Center/Panel/Close/Close

onready var _emailPassword = $Container/Viewport/Interface/Email/Center/Panel/VBox/Panel/VBox/Password
onready var _emailEmail    = $Container/Viewport/Interface/Email/Center/Panel/VBox/Panel/VBox/Email
onready var _emailConfirm  = $Container/Viewport/Interface/Email/Center/Panel/VBox/Panel/VBox/Confirm
onready var _emailChange   = $Container/Viewport/Interface/Email/Center/Panel/VBox/Change
onready var _emailClose    = $Container/Viewport/Interface/Email/Center/Panel/Close/Close

onready var _passwordOld     = $Container/Viewport/Interface/Password/Center/Panel/VBox/Panel/VBox/Old
onready var _passwordNew     = $Container/Viewport/Interface/Password/Center/Panel/VBox/Panel/VBox/New
onready var _passwordConfirm = $Container/Viewport/Interface/Password/Center/Panel/VBox/Panel/VBox/Confirm
onready var _passwordChange  = $Container/Viewport/Interface/Password/Center/Panel/VBox/Change
onready var _passwordClose   = $Container/Viewport/Interface/Password/Center/Panel/Close/Close

onready var _dialog = $Container/Viewport/Dialog

onready var _messageTitle = $Container/Viewport/Dialog/Message/Center/Panel/VBox/Title
onready var _messageText  = $Container/Viewport/Dialog/Message/Center/Panel/VBox/Panel/Text
onready var _messageClose = $Container/Viewport/Dialog/Message/Center/Panel/Close/Close

onready var _http = $HTTPRequest
onready var _tween = $Tween
onready var _clickAudio = $Click
onready var _errorAudio = $Error

const _signInPosition = Vector2(0, 3000)
const _signUpPosition = Vector2(3000, 3000)
const _resetPosition = Vector2(-3000, 3000)

const _accountPosition = Vector2(0, -3000)
const _emailPosition = Vector2(3000, -3000)
const _passwordPosition = Vector2(-3000, -3000)

const _messagePosition = Vector2(3000, 0)

const _connectedColor = Color(0.5, 0.75, 0.5)
const _disconnectedColor = Color(0.75, 0.5, 0.5)

const _springTime = 0.333

var _f = File.new()
var _state = { "email": "", "token": "" }
const _statePath = "user://state.txt";
var _regex = RegEx.new()
const _pattern = "(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+$)"

func _ready():
	Utility.ok(_status.connect("pressed", self, "_on_Status_pressed"))
	
	Utility.ok(_signInSignIn.connect("pressed", self, "_on_SignIn_pressed"))
	Utility.ok(_signInSignUp.connect("pressed", self, "_on_SignInSignUo_pressed"))
	Utility.ok(_signInReset.connect("pressed", self, "_on_SignInReset_pressed"))
	Utility.ok(_signInClose.connect("pressed", self, "_on_Close_pressed"))
	
	Utility.ok(_signUpSignUp.connect("pressed", self, "_on_SignUp_pressed"))
	Utility.ok(_signUpClose.connect("pressed", self, "_on_CloseSignIn_pressed"))
	
	Utility.ok(_resetReset.connect("pressed", self, "_on_Reset_pressed"))
	Utility.ok(_resetClose.connect("pressed", self, "_on_CloseSignIn_pressed"))
	
	Utility.ok(_accountSignOut.connect("pressed", self, "_on_SignOut_pressed"))
	Utility.ok(_accountChangeEmail.connect("pressed", self, "_on_AccountChangeEmail_pressed"))
	Utility.ok(_accountChangePassword.connect("pressed", self, "_on_AccountChangePassword_pressed"))
	Utility.ok(_accountClose.connect("pressed", self, "_on_Close_pressed"))
	
	Utility.ok(_emailChange.connect("pressed", self, "_on_ChangeEmail_pressed"))
	Utility.ok(_emailClose.connect("pressed", self, "_on_CloseAccount_pressed"))

	Utility.ok(_passwordChange.connect("pressed", self, "_on_ChangePassword_pressed"))
	Utility.ok(_passwordClose.connect("pressed", self, "_on_CloseAccount_pressed"))
	
	Utility.ok(_messageClose.connect("pressed", self, "_springMessageBack"))

	Utility.ok(Firebase.connect("signedIn", self, "_onSignedIn"))
	Utility.ok(Firebase.connect("signedUp", self, "_onSignedUp"))
	Utility.ok(Firebase.connect("reset", self, "_onReset"))
	Utility.ok(Firebase.connect("signedOut", self, "_onSignedOut"))
	# _loadEmail()
	_updateStatus()
	_regex.compile(_pattern)

func _spring(p = Vector2.ZERO, c = _interface):
	var current = c.get_position()
	if  not current.is_equal_approx(p):
		if _tween.interpolate_property(c, "rect_position", current, p, _springTime, Tween.TRANS_ELASTIC, Tween.EASE_OUT):
			if not _tween.start():
				print("error")

func _springSignIn():
	_spring(_signInPosition)

func _springSignUp():
	_spring(_signUpPosition)

func _springReset():
	_spring(_resetPosition)

func _springAccount():
	_spring(_accountPosition)

func _springEmail():
	_spring(_emailPosition)

func _springPassword():
	_spring(_passwordPosition)

func _springMessage():
	_spring(_messagePosition, _dialog)

func _springMessageBack():
	_clickAudio.play()
	_spring(Vector2.ZERO, _dialog)

func _showError(title, text):
	_errorAudio.play()
	_messageTitle.text = title
	_messageText.text = text
	_springMessage()

func _on_Status_pressed():
	_clickAudio.play()
	if not Firebase.authenticated():
		_springSignIn()
	else:
		_springAccount()

func _updateStatus():
	if Firebase.authenticated():
		_status.modulate = _connectedColor
	else:
		_status.modulate = _disconnectedColor

func _on_SignIn_pressed():
	_clickAudio.play()
	var email = _signInEmail.text
	var password = _signInPassword.text
	_errorClear([_signInEmail, _signInPassword])
	if email.empty() or not _validEmail(email):
		_errorSet(_signInEmail)
		return
	if password.empty() or not _validPassword(password):
		_errorSet(_signInPassword)
		return
	_disableInput(_signInSignIn)
	Firebase.signIn(_http, email, password)
	# _saveEmail()

func _on_SignInSignUo_pressed():
	_clickAudio.play()
	_springSignUp()

func _on_SignInReset_pressed():
	_clickAudio.play()
	_springReset()

func _on_Close_pressed():
	_clickAudio.play()
	_spring()

func _on_CloseSignIn_pressed():
	_clickAudio.play()
	_springSignIn()

func _on_CloseAccount_pressed():
	_clickAudio.play()
	_springAccount()

func _onSignedIn(response):
	if response[1] == 200:
		_signInPassword.text = ""
		_updateStatus()
		_spring()
	else:
		var o = JSON.parse(response[3].get_string_from_ascii()).result as Dictionary
		_showError("Error", o.error.message.capitalize())
	_enableInput(_signInSignIn)

func _on_SignUp_pressed():
	_clickAudio.play()
	var email = _signUpEmail.text
	var password = _signUpPassword.text
	var confirm = _signUpConfirm.text
	_errorClear([_signUpEmail, _signUpPassword, _signUpConfirm])
	if email.empty() or not _validEmail(email):
		_errorSet(_signUpEmail)
		return
	if password.empty() or not _validPassword(password):
		_errorSet(_signUpPassword)
		return
	if confirm != password:
		_errorSet(_signUpConfirm)
		return
	_disableInput(_signUpSignUp)
	Firebase.signUp(_http, email, password)
	# _saveEmail()

func _onSignedUp(response):
	if response[1] == 200:
		_updateStatus()
		_spring()
	else:
		var o = JSON.parse(response[3].get_string_from_ascii()).result as Dictionary
		_showError("Error", o.error.message.capitalize())
	_enableInput(_signUpSignUp)

func _on_Reset_pressed():
	if not _resetEmail.text.empty():
		Firebase.reset(_http, _resetEmail.text)

func _onReset():
	_springSignIn()

func _on_SignOut_pressed():
	_clickAudio.play()
	Firebase.signOut()

func _onSignedOut():
	_updateStatus()
	_spring()

func _on_AccountChangeEmail_pressed():
	_clickAudio.play()
	_springEmail()
	pass

func _on_AccountChangePassword_pressed():
	_clickAudio.play()
	_springPassword()
	pass

# func _saveEmail(email: String):
# 	if not email.empty():
# 		f.open(emailPath, File.WRITE)
# 		f.store_string(email)
# 		f.close()

# func _loadEmail() -> String:
# 	var email = ""
# 	if f.file_exists(emailPath):
# 		f.open(emailPath, File.READ)
# 		email = f.get_as_text()
# 		f.close()
# 	return email

func _validEmail(text: String) -> bool:
	return _regex.search(text)

func _validPassword(text: String) -> bool:
	return text.length() > 2

func _errorClear(controls: Array):
	for i in range(controls.size()):
		controls[i].modulate = Color.white

func _errorSet(control: LineEdit):
	_errorAudio.play()
	control.modulate = _disconnectedColor

func _disableInput(control: Button):
	control.disabled = true

func _enableInput(control: Button):
	control.disabled = false;
