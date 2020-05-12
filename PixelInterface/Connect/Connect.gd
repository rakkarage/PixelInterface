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

export var _accept : ShortCut
var _currentAccept : Control
export var _cancel : ShortCut
var _currentCancel : Control

const _rememberPath := "user://remember.txt"
var _f := File.new()

func _ready():
	Utility.ok(_status.connect("pressed", self, "_on_Status_pressed"))

	Utility.ok(_signInRemember.connect("pressed", self, "_on_Remember_pressed"))
	Utility.ok(_signInSignIn.connect("pressed", self, "_on_SignIn_pressed"))
	Utility.ok(_signInSignUp.connect("pressed", self, "_springSignUp"))
	Utility.ok(_signInReset.connect("pressed", self, "_springReset"))
	Utility.ok(_signInClose.connect("pressed", self, "_springStatus"))

	Utility.ok(_signUpSignUp.connect("pressed", self, "_on_SignUp_pressed"))
	Utility.ok(_signUpClose.connect("pressed", self, "_springSignIn"))

	Utility.ok(_resetReset.connect("pressed", self, "_on_Reset_pressed"))
	Utility.ok(_resetClose.connect("pressed", self, "_springSignIn"))

	Utility.ok(_accountSignOut.connect("pressed", self, "_on_SignOut_pressed"))
	Utility.ok(_accountChangeEmail.connect("pressed", self, "_springEmail"))
	Utility.ok(_accountChangePassword.connect("pressed", self, "_springPassword"))
	Utility.ok(_accountClose.connect("pressed", self, "_springStatus"))

	Utility.ok(_emailChange.connect("pressed", self, "_on_ChangeEmail_pressed"))
	Utility.ok(_emailClose.connect("pressed", self, "_springAccount"))

	Utility.ok(_passwordChange.connect("pressed", self, "_on_ChangePassword_pressed"))
	Utility.ok(_passwordClose.connect("pressed", self, "_springAccount"))

	Utility.ok(_messageClose.connect("pressed", self, "_hideError"))

	Utility.ok(_dataSave.connect("pressed", self, "_saveDoc"))
	Utility.ok(_dataDelete.connect("pressed", self, "_deleteDoc"))

	Utility.ok(_regex.compile(_pattern))
