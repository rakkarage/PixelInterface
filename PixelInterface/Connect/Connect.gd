extends Control
class_name Connect

onready var _interface := $Container/Viewport/Interface

onready var _status      := $Container/Viewport/Interface/Status/Panel/Status
onready var _statusEmail := $Container/Viewport/Interface/Status/Panel/Margin/Panel/Email

onready var _signInEmail    := $Container/Viewport/Interface/SignIn/Center/Panel/VBox/Panel/VBox/Email
onready var _signInPassword := $Container/Viewport/Interface/SignIn/Center/Panel/VBox/Panel/VBox/Password
onready var _signInRemember := $Container/Viewport/Interface/SignIn/Center/Panel/VBox/Remember
onready var _signInSignIn   := $Container/Viewport/Interface/SignIn/Center/Panel/VBox/SignIn
onready var _signInSignUp   := $Container/Viewport/Interface/SignIn/Center/Panel/VBox/HBox/SignUp
onready var _signInReset    := $Container/Viewport/Interface/SignIn/Center/Panel/VBox/HBox/Reset
onready var _signInClose    := $Container/Viewport/Interface/SignIn/Center/Panel/Close/Close

onready var _signUpName     := $Container/Viewport/Interface/SignUp/Center/Panel/VBox/Panel/VBox/HBox/Name
onready var _signUpNext     := $Container/Viewport/Interface/SignUp/Center/Panel/VBox/Panel/VBox/HBox/Next
onready var _signUpEmail    := $Container/Viewport/Interface/SignUp/Center/Panel/VBox/Panel/VBox/Email
onready var _signUpPassword := $Container/Viewport/Interface/SignUp/Center/Panel/VBox/Panel/VBox/Password
onready var _signUpConfirm  := $Container/Viewport/Interface/SignUp/Center/Panel/VBox/Panel/VBox/Confirm
onready var _signUpSignUp   := $Container/Viewport/Interface/SignUp/Center/Panel/VBox/SignUp
onready var _signUpClose    := $Container/Viewport/Interface/SignUp/Center/Panel/Close/Close

onready var _resetEmail := $Container/Viewport/Interface/Reset/Center/Panel/VBox/Panel/Email
onready var _resetReset := $Container/Viewport/Interface/Reset/Center/Panel/VBox/Reset
onready var _resetClose := $Container/Viewport/Interface/Reset/Center/Panel/Close/Close

onready var _accountEmail          := $Container/Viewport/Interface/Account/Center/Panel/VBox/Panel/Email
onready var _accountSignOut        := $Container/Viewport/Interface/Account/Center/Panel/VBox/SignOut
onready var _accountChangeEmail    := $Container/Viewport/Interface/Account/Center/Panel/VBox/HBox/Email
onready var _accountChangePassword := $Container/Viewport/Interface/Account/Center/Panel/VBox/HBox/Password
onready var _accountClose          := $Container/Viewport/Interface/Account/Center/Panel/Close/Close

onready var _emailPassword := $Container/Viewport/Interface/Email/Center/Panel/VBox/Panel/VBox/Password
onready var _emailEmail    := $Container/Viewport/Interface/Email/Center/Panel/VBox/Panel/VBox/Email
onready var _emailConfirm  := $Container/Viewport/Interface/Email/Center/Panel/VBox/Panel/VBox/Confirm
onready var _emailChange   := $Container/Viewport/Interface/Email/Center/Panel/VBox/Change
onready var _emailClose    := $Container/Viewport/Interface/Email/Center/Panel/Close/Close

onready var _passwordPassword := $Container/Viewport/Interface/Password/Center/Panel/VBox/Panel/VBox/Password
onready var _passwordConfirm  := $Container/Viewport/Interface/Password/Center/Panel/VBox/Panel/VBox/Confirm
onready var _passwordChange   := $Container/Viewport/Interface/Password/Center/Panel/VBox/Change
onready var _passwordClose    := $Container/Viewport/Interface/Password/Center/Panel/Close/Close

onready var _dialog := $Container/Viewport/Dialog

onready var _messageTitle := $Container/Viewport/Dialog/Message/Center/Panel/VBox/Title
onready var _messageText  := $Container/Viewport/Dialog/Message/Center/Panel/VBox/Panel/Text
onready var _messageClose := $Container/Viewport/Dialog/Message/Center/Panel/Close/Close

onready var _dataTitle :=  $Container/Viewport/Interface/Data/Center/Panel/VBox/Panel/VBox/Title
onready var _dataNumber := $Container/Viewport/Interface/Data/Center/Panel/VBox/Panel/VBox/Number
onready var _dataText :=   $Container/Viewport/Interface/Data/Center/Panel/VBox/Panel/VBox/Text
onready var _dataSave :=   $Container/Viewport/Interface/Data/Center/Panel/VBox/HBox/Save
onready var _dataDelete := $Container/Viewport/Interface/Data/Center/Panel/VBox/HBox/Delete

onready var _http := $HTTPRequest
onready var _tween := $Tween
onready var _clickAudio := $Click
onready var _errorAudio := $Error
onready var _successAudio := $Success

const _anchor := Rect2(0, 0, 1, 1)

const _signInAnchor := Rect2(0, 1, 1, 2)
const _signUpAnchor := Rect2(1, 1, 2, 2)
const _resetAnchor := Rect2(-1, 1, 0, 2)

const _accountAnchor := Rect2(0, -1, 1, 0)
const _emailAnchor := Rect2(1, -1, 2, 0)
const _passwordAnchor := Rect2(-1, -1, 0, 0)

const _messageAnchor := Rect2(1, 0, 2, 1)

const _connectedColor := Color(0.5, 0.75, 0.5)
const _disconnectedColor := Color(0.75, 0.5, 0.5)

const _time := 0.333
const _trans := Tween.TRANS_EXPO
const _ease := Tween.EASE_OUT

var _regex := RegEx.new()
const _pattern := "(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+$)"

var _focusStack : Array = [ null ]
export var _accept : ShortCut
var _acceptStack : Array = [ null ]
export var _cancel : ShortCut
var _cancelStack : Array = [ null ]

var _gename = Gename.new()

func _ready():
	Utility.ok(_status.connect("pressed", self, "_onStatusPressed"))

	Utility.ok(_signInRemember.connect("pressed", self, "_onRememberPressed"))
	Utility.ok(_signInSignIn.connect("pressed", self, "_onSignInPressed"))
	Utility.ok(_signInSignUp.connect("pressed", self, "_springSignUp"))
	Utility.ok(_signInReset.connect("pressed", self, "_springReset"))
	Utility.ok(_signInClose.connect("pressed", self, "_springStatus"))

	Utility.ok(_signUpNext.connect("pressed", self, "_onNextNamePressed"))
	Utility.ok(_signUpSignUp.connect("pressed", self, "_onSignUpPressed"))
	Utility.ok(_signUpClose.connect("pressed", self, "_springSignIn"))

	Utility.ok(_resetReset.connect("pressed", self, "_onResetPressed"))
	Utility.ok(_resetClose.connect("pressed", self, "_springSignIn"))

	Utility.ok(_accountSignOut.connect("pressed", self, "_onSignOutPressed"))
	Utility.ok(_accountChangeEmail.connect("pressed", self, "_springEmail"))
	Utility.ok(_accountChangePassword.connect("pressed", self, "_springPassword"))
	Utility.ok(_accountClose.connect("pressed", self, "_springStatus"))

	Utility.ok(_emailChange.connect("pressed", self, "_onChangeEmailPressed"))
	Utility.ok(_emailClose.connect("pressed", self, "_springAccount"))

	Utility.ok(_passwordChange.connect("pressed", self, "_onChangePasswordPressed"))
	Utility.ok(_passwordClose.connect("pressed", self, "_springAccount"))

	Utility.ok(_messageClose.connect("pressed", self, "_onCloseErrorPressed"))

	Utility.ok(_dataSave.connect("pressed", self, "_onSaveDocPressed"))
	Utility.ok(_dataDelete.connect("pressed", self, "_onDeleteDocPressed"))

	Utility.ok(_regex.compile(_pattern))

	_signUpName.text = _gename.next()

func _onNextNamePressed() -> void:
	_clickAudio.play()
	_signUpName.text = _gename.next()

func _onRememberPressed() -> void:
	Store.data.all.remember = _signInRemember.pressed
	Store.write()

func _clearFocus() -> void:
	var accept = _acceptStack[0]
	if accept != null: accept.shortcut = null
	var cancel = _cancelStack[0]
	if cancel != null: cancel.shortcut = null

func _applyFocus() -> void:
	_focusStack[0].grab_focus()
	var accept = _acceptStack[0]
	if accept != null: accept.shortcut = _accept
	var cancel = _cancelStack[0]
	if cancel != null: cancel.shortcut = _cancel

func _popFocus() -> void:
	_clearFocus()
	_focusStack.pop_front()
	_acceptStack.pop_front()
	_cancelStack.pop_front()
	_applyFocus()

func _pushFocus(focus: Control, accept: Control, cancel: Control):
	_clearFocus()
	_focusStack.push_front(focus)
	_acceptStack.push_front(accept)
	_cancelStack.push_front(cancel)
	_applyFocus()

func _focus(focus: Control, accept: Control, cancel: Control):
	_clearFocus()
	_focusStack[0] = focus
	_acceptStack[0] = accept
	_cancelStack[0] = cancel
	_applyFocus()

func _showError(error: String) -> void:
	_errorAudio.play()
	_messageClose.grab_focus()
	_messageTitle.text = "Error"
	_messageText.text = error
	_spring(_messageAnchor, _dialog, false)
	_pushFocus(_messageClose, _messageClose, _messageClose)

func _onCloseErrorPressed() -> void:
	_clickAudio.play()
	_spring(_anchor, _dialog)
	_popFocus()

func _spring(a := _anchor, c := _interface, click := true) -> void:
	if click: _clickAudio.play()
	_tween.interpolate_property(c, "anchor_left", null, a.position.x, _time, _trans, _ease)
	_tween.interpolate_property(c, "anchor_top", null, a.position.y, _time, _trans, _ease)
	_tween.interpolate_property(c, "anchor_right", null, a.size.x, _time, _trans, _ease)
	_tween.interpolate_property(c, "anchor_bottom", null, a.size.y, _time, _trans, _ease)
	_tween.start()

func _springStatus(click := true) -> void:
	_focus(_status, _status, null)
	_spring(_anchor, _interface, click)

func _springSignIn(click := true) -> void:
	_focus(_signInEmail, _signInSignIn, _signInClose)
	_spring(_signInAnchor, _interface, click)

func _springSignUp() -> void:
	_focus(_signUpEmail, _signUpSignUp, _signUpClose)
	_spring(_signUpAnchor)

func _springReset() -> void:
	_focus(_resetEmail, _resetReset, _resetClose)
	_spring(_resetAnchor)

func _springAccount(click := true) -> void:
	_focus(_accountSignOut, _accountSignOut, _accountClose)
	_spring(_accountAnchor, _interface, click)

func _springEmail() -> void:
	_focus(_emailEmail, _emailChange, _emailClose)
	_spring(_emailAnchor)

func _springPassword() -> void:
	_focus(_passwordPassword, _passwordChange, _passwordClose)
	_spring(_passwordAnchor)

func _validEmail(text: String) -> bool: return _regex.search(text) != null

# firebase requires 3 nakama requires 8
func _validPassword(text: String) -> bool: return text.length() > 7

func _errorClear(controls: Array) -> void:
	for i in range(controls.size()):
		controls[i].modulate = Color.white

func _errorSet(control: Control) -> void:
	_errorAudio.play()
	control.modulate = _disconnectedColor

func _disableInput(controls: Array) -> void:
	_enableWait()
	for control in controls:
		control.disabled = true

func _enableInput(controls: Array) -> void:
	_disableWait()
	for control in controls:
		control.disabled = false

func _enableWait() -> void: Cursor.wait = true

func _disableWait() -> void: Cursor.wait = false
