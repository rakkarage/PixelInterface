extends Node
class_name Connect

@warning_ignore("unused_private_class_variable")

@onready var _interface := $Container/SubViewport/Interface

@onready var _status      := $Container/SubViewport/Interface/Status/Panel/Status
@onready var _statusEmail := $Container/SubViewport/Interface/Status/Panel/Margin/Panel/Email

@onready var _signInEmail    := $Container/SubViewport/Interface/SignIn/Center/Panel/VBox/Panel/VBox/Email
@onready var _signInPassword := $Container/SubViewport/Interface/SignIn/Center/Panel/VBox/Panel/VBox/Password
@onready var _signInRemember := $Container/SubViewport/Interface/SignIn/Center/Panel/VBox/Remember
@onready var _signInSignIn   := $Container/SubViewport/Interface/SignIn/Center/Panel/VBox/SignIn
@onready var _signInSignUp   := $Container/SubViewport/Interface/SignIn/Center/Panel/VBox/HBox/SignUp
@onready var _signInReset    := $Container/SubViewport/Interface/SignIn/Center/Panel/VBox/HBox/Reset
@onready var _signInClose    := $Container/SubViewport/Interface/SignIn/Center/Panel/Close/Close

@onready var _signUpName     := $Container/SubViewport/Interface/SignUp/Center/Panel/VBox/Panel/VBox/HBox/Name
@onready var _signUpNext     := $Container/SubViewport/Interface/SignUp/Center/Panel/VBox/Panel/VBox/HBox/Next
@onready var _signUpEmail    := $Container/SubViewport/Interface/SignUp/Center/Panel/VBox/Panel/VBox/Email
@onready var _signUpPassword := $Container/SubViewport/Interface/SignUp/Center/Panel/VBox/Panel/VBox/Password
@onready var _signUpConfirm  := $Container/SubViewport/Interface/SignUp/Center/Panel/VBox/Panel/VBox/Confirm
@onready var _signUpSignUp   := $Container/SubViewport/Interface/SignUp/Center/Panel/VBox/SignUp
@onready var _signUpClose    := $Container/SubViewport/Interface/SignUp/Center/Panel/Close/Close

@onready var _resetEmail := $Container/SubViewport/Interface/Reset/Center/Panel/VBox/Panel/Email
@onready var _resetReset := $Container/SubViewport/Interface/Reset/Center/Panel/VBox/Reset
@onready var _resetClose := $Container/SubViewport/Interface/Reset/Center/Panel/Close/Close

@onready var _accountName           := $Container/SubViewport/Interface/Account/Center/Panel/VBox/Panel/VBox/Name
@onready var _accountEmail          := $Container/SubViewport/Interface/Account/Center/Panel/VBox/Panel/VBox/Email
@onready var _accountSignOut        := $Container/SubViewport/Interface/Account/Center/Panel/VBox/SignOut
@onready var _accountChangeEmail    := $Container/SubViewport/Interface/Account/Center/Panel/VBox/HBox/Email
@onready var _accountChangePassword := $Container/SubViewport/Interface/Account/Center/Panel/VBox/HBox/Password
@onready var _accountClose          := $Container/SubViewport/Interface/Account/Center/Panel/Close/Close

@onready var _emailPassword := $Container/SubViewport/Interface/Email/Center/Panel/VBox/Panel/VBox/Password
@onready var _emailEmail    := $Container/SubViewport/Interface/Email/Center/Panel/VBox/Panel/VBox/Email
@onready var _emailConfirm  := $Container/SubViewport/Interface/Email/Center/Panel/VBox/Panel/VBox/Confirm
@onready var _emailChange   := $Container/SubViewport/Interface/Email/Center/Panel/VBox/Change
@onready var _emailClose    := $Container/SubViewport/Interface/Email/Center/Panel/Close/Close

@onready var _passwordPassword := $Container/SubViewport/Interface/Password/Center/Panel/VBox/Panel/VBox/Password
@onready var _passwordConfirm  := $Container/SubViewport/Interface/Password/Center/Panel/VBox/Panel/VBox/Confirm
@onready var _passwordChange   := $Container/SubViewport/Interface/Password/Center/Panel/VBox/Change
@onready var _passwordClose    := $Container/SubViewport/Interface/Password/Center/Panel/Close/Close

@onready var _dialog := $Container/SubViewport/Dialog

@onready var _messageTitle := $Container/SubViewport/Dialog/Center/Panel/VBox/Title
@onready var _messageText  := $Container/SubViewport/Dialog/Center/Panel/VBox/Panel/Text
@onready var _messageClose := $Container/SubViewport/Dialog/Center/Panel/Close/Close

@onready var _dataTitle :=  $Container/SubViewport/Interface/Data/Center/Panel/VBox/Panel/VBox/Title
@onready var _dataNumber := $Container/SubViewport/Interface/Data/Center/Panel/VBox/Panel/VBox/Number
@onready var _dataText :=   $Container/SubViewport/Interface/Data/Center/Panel/VBox/Panel/VBox/Text
@onready var _dataSave :=   $Container/SubViewport/Interface/Data/Center/Panel/VBox/HBox/Save
@onready var _dataDelete := $Container/SubViewport/Interface/Data/Center/Panel/VBox/HBox/Delete

@onready var _http := $HTTPRequest
@onready var _clickAudio := $Click
@onready var _errorAudio := $Error
@onready var _successAudio := $Success

const _anchor := Rect2(0, 0, 1, 1)

const _signInAnchor := Rect2(0, 1, 1, 2)
const _signUpAnchor := Rect2(1, 1, 2, 2)
const _resetAnchor := Rect2(-1, 1, 0, 2)

const _accountAnchor := Rect2(0, -1, 1, 0)
const _emailAnchor := Rect2(1, -1, 2, 0)
const _passwordAnchor := Rect2(-1, -1, 0, 0)

const _messageAnchor := Rect2(0, 0, 1, 1)
const _messageAnchorBack := Rect2(-1, 0, 0, 1)

const _connectedColor := Color(0.5, 0.75, 0.5)
const _disconnectedColor := Color(0.75, 0.5, 0.5)

const _time := 0.333
const _trans := Tween.TRANS_EXPO
const _ease := Tween.EASE_OUT

var _regex := RegEx.new()
const _pattern := "(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+$)"

var _focusStack : Array = [ null ]
@export var _accept : Shortcut
var _acceptStack : Array = [ null ]
@export var _cancel : Shortcut
var _cancelStack : Array = [ null ]

var _gename = Gename.new()

func _ready():
	_status.connect("pressed", Callable(self, "_onStatusPressed"))

	_signInRemember.connect("pressed", Callable(self, "_onRememberPressed"))
	_signInSignIn.connect("pressed", Callable(self, "_onSignInPressed"))
	_signInSignUp.connect("pressed", Callable(self, "_springSignUp"))
	_signInReset.connect("pressed", Callable(self, "_springReset"))
	_signInClose.connect("pressed", Callable(self, "_springStatus"))

	_signUpNext.connect("pressed", Callable(self, "_onNextNamePressed"))
	_signUpSignUp.connect("pressed", Callable(self, "_onSignUpPressed"))
	_signUpClose.connect("pressed", Callable(self, "_springSignIn"))

	_resetReset.connect("pressed", Callable(self, "_onResetPressed"))
	_resetClose.connect("pressed", Callable(self, "_springSignIn"))

	_accountSignOut.connect("pressed", Callable(self, "_onSignOutPressed"))
	_accountChangeEmail.connect("pressed", Callable(self, "_springEmail"))
	_accountChangePassword.connect("pressed", Callable(self, "_springPassword"))
	_accountClose.connect("pressed", Callable(self, "_springStatus"))

	_emailChange.connect("pressed", Callable(self, "_onChangeEmailPressed"))
	_emailClose.connect("pressed", Callable(self, "_springAccount"))

	_passwordChange.connect("pressed", Callable(self, "_onChangePasswordPressed"))
	_passwordClose.connect("pressed", Callable(self, "_springAccount"))

	_messageClose.connect("pressed", Callable(self, "_onCloseErrorPressed"))

	_dataSave.connect("pressed", Callable(self, "_onSaveDocPressed"))
	_dataDelete.connect("pressed", Callable(self, "_onDeleteDocPressed"))

	_regex.compile(_pattern)

	_signUpName.text = _gename.next()
	_focus(_status, _status, null)

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
	_spring(_messageAnchorBack, _dialog)
	_popFocus()

func _spring(a := _anchor, c := _interface, click := true) -> void:
	if click: _clickAudio.play()
	var tween = create_tween()
	tween.set_trans(_trans).set_ease(_ease)
	tween.tween_property(c, "anchor_left", a.position.x, _time)
	tween.parallel().tween_property(c, "anchor_top", a.position.y, _time)
	tween.parallel().tween_property(c, "anchor_right", a.size.x, _time)
	tween.parallel().tween_property(c, "anchor_bottom", a.size.y, _time)

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
		controls[i].modulate = Color.WHITE

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
