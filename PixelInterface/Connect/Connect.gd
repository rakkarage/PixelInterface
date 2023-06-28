extends Node
class_name Connect

@warning_ignore("unused_private_class_variable") # TODO: Buggy!?

@onready var _interface := $Container/SubViewport/Interface

@onready var _status       := $Container/SubViewport/Interface/Status/Panel/Status
@onready var _status_email := $Container/SubViewport/Interface/Status/Panel/Margin/Panel/Email

@onready var _sign_in_email    := $Container/SubViewport/Interface/SignIn/Center/Panel/VBox/Panel/VBox/Email
@onready var _sign_in_password := $Container/SubViewport/Interface/SignIn/Center/Panel/VBox/Panel/VBox/Password
@onready var _sign_in_remember := $Container/SubViewport/Interface/SignIn/Center/Panel/VBox/Remember
@onready var _sign_in_sign_in  := $Container/SubViewport/Interface/SignIn/Center/Panel/VBox/SignIn
@onready var _sign_in_sign_up  := $Container/SubViewport/Interface/SignIn/Center/Panel/VBox/HBox/SignUp
@onready var _sign_in_reset    := $Container/SubViewport/Interface/SignIn/Center/Panel/VBox/HBox/Reset
@onready var _sign_in_close    := $Container/SubViewport/Interface/SignIn/Center/Panel/Close/Close

@onready var _sign_up_name     := $Container/SubViewport/Interface/SignUp/Center/Panel/VBox/Panel/VBox/HBox/Name
@onready var _sign_up_next     := $Container/SubViewport/Interface/SignUp/Center/Panel/VBox/Panel/VBox/HBox/Next
@onready var _sign_up_email    := $Container/SubViewport/Interface/SignUp/Center/Panel/VBox/Panel/VBox/Email
@onready var _sign_up_password := $Container/SubViewport/Interface/SignUp/Center/Panel/VBox/Panel/VBox/Password
@onready var _sign_up_confirm  := $Container/SubViewport/Interface/SignUp/Center/Panel/VBox/Panel/VBox/Confirm
@onready var _sign_up_sign_up  := $Container/SubViewport/Interface/SignUp/Center/Panel/VBox/SignUp
@onready var _sign_up_close    := $Container/SubViewport/Interface/SignUp/Center/Panel/Close/Close

@onready var _reset_email := $Container/SubViewport/Interface/Reset/Center/Panel/VBox/Panel/Email
@onready var _reset_reset := $Container/SubViewport/Interface/Reset/Center/Panel/VBox/Reset
@onready var _reset_close := $Container/SubViewport/Interface/Reset/Center/Panel/Close/Close

@onready var _account_name            := $Container/SubViewport/Interface/Account/Center/Panel/VBox/Panel/VBox/Name
@onready var _account_email           := $Container/SubViewport/Interface/Account/Center/Panel/VBox/Panel/VBox/Email
@onready var _account_sign_out        := $Container/SubViewport/Interface/Account/Center/Panel/VBox/SignOut
@onready var _account_change_email    := $Container/SubViewport/Interface/Account/Center/Panel/VBox/HBox/Email
@onready var _account_change_password := $Container/SubViewport/Interface/Account/Center/Panel/VBox/HBox/Password
@onready var _account_close           := $Container/SubViewport/Interface/Account/Center/Panel/Close/Close

@onready var _email_password := $Container/SubViewport/Interface/Email/Center/Panel/VBox/Panel/VBox/Password
@onready var _email_email    := $Container/SubViewport/Interface/Email/Center/Panel/VBox/Panel/VBox/Email
@onready var _email_confirm  := $Container/SubViewport/Interface/Email/Center/Panel/VBox/Panel/VBox/Confirm
@onready var _email_change   := $Container/SubViewport/Interface/Email/Center/Panel/VBox/Change
@onready var _email_close    := $Container/SubViewport/Interface/Email/Center/Panel/Close/Close

@onready var _password_password := $Container/SubViewport/Interface/Password/Center/Panel/VBox/Panel/VBox/Password
@onready var _password_confirm  := $Container/SubViewport/Interface/Password/Center/Panel/VBox/Panel/VBox/Confirm
@onready var _password_change   := $Container/SubViewport/Interface/Password/Center/Panel/VBox/Change
@onready var _password_close    := $Container/SubViewport/Interface/Password/Center/Panel/Close/Close

@onready var _dialog := $Container/SubViewport/Dialog

@onready var _message_title := $Container/SubViewport/Dialog/Center/Panel/VBox/Title
@onready var _message_text  := $Container/SubViewport/Dialog/Center/Panel/VBox/Panel/Text
@onready var _message_close := $Container/SubViewport/Dialog/Center/Panel/Close/Close

@onready var _data_title  := $Container/SubViewport/Interface/Data/Center/Panel/VBox/Panel/VBox/Title
@onready var _data_number := $Container/SubViewport/Interface/Data/Center/Panel/VBox/Panel/VBox/Number
@onready var _data_text   := $Container/SubViewport/Interface/Data/Center/Panel/VBox/Panel/VBox/Text
@onready var _data_save   := $Container/SubViewport/Interface/Data/Center/Panel/VBox/HBox/Save
@onready var _data_delete := $Container/SubViewport/Interface/Data/Center/Panel/VBox/HBox/Delete

@onready var _http := $HTTPRequest

const _anchor := Rect2(0, 0, 1, 1)

const _sign_in_anchor := Rect2(0, 1, 1, 2)
const _sign_up_anchor := Rect2(1, 1, 2, 2)
const _reset_anchor := Rect2(-1, 1, 0, 2)

const _account_anchor := Rect2(0, -1, 1, 0)
const _email_anchor := Rect2(1, -1, 2, 0)
const _password_anchor := Rect2(-1, -1, 0, 0)

const _message_anchor := Rect2(0, 0, 1, 1)
const _message_anchor_back := Rect2(-1, 0, 0, 1)

const _connected_color := Color(0.5, 0.75, 0.5)
const _disconnected_color := Color(0.75, 0.5, 0.5)

const _time := 0.333
const _trans := Tween.TRANS_EXPO
const _ease := Tween.EASE_OUT

var _regex := RegEx.new()
const _pattern := "(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+$)"

var _focus_stack : Array = [ null ]
@export var _accept : Shortcut
var _accept_stack : Array = [ null ]
@export var _cancel : Shortcut
var _cancel_stack : Array = [ null ]

var _gename = Gename.new()

func _ready():
	_status.connect("pressed", Callable(self, "_on_status_pressed"))

	_sign_in_remember.connect("pressed", Callable(self, "_on_remember_pressed"))
	_sign_in_sign_in.connect("pressed", Callable(self, "_on_sign_in_pressed"))
	_sign_in_sign_up.connect("pressed", Callable(self, "_spring_sign_up"))
	_sign_in_reset.connect("pressed", Callable(self, "_spring_reset"))
	_sign_in_close.connect("pressed", Callable(self, "_spring_status"))

	_sign_up_next.connect("pressed", Callable(self, "_on_next_name_pressed"))
	_sign_up_sign_up.connect("pressed", Callable(self, "_on_sign_up_pressed"))
	_sign_up_close.connect("pressed", Callable(self, "_spring_sign_in"))

	_reset_reset.connect("pressed", Callable(self, "_on_reset_pressed"))
	_reset_close.connect("pressed", Callable(self, "_spring_sign_in"))

	_account_sign_out.connect("pressed", Callable(self, "_on_sign_out_pressed"))
	_account_change_email.connect("pressed", Callable(self, "_spring_email"))
	_account_change_password.connect("pressed", Callable(self, "_spring_password"))
	_account_close.connect("pressed", Callable(self, "_spring_status"))

	_email_change.connect("pressed", Callable(self, "_on_change_email_pressed"))
	_email_close.connect("pressed", Callable(self, "_spring_account"))

	_password_change.connect("pressed", Callable(self, "_on_change_password_pressed"))
	_password_close.connect("pressed", Callable(self, "_spring_account"))

	_message_close.connect("pressed", Callable(self, "_on_close_error_pressed"))

	_data_save.connect("pressed", Callable(self, "_on_save_doc_pressed"))
	_data_delete.connect("pressed", Callable(self, "_on_delete_doc_pressed"))

	_regex.compile(_pattern)

	_sign_up_name.text = _gename.next()
	_focus(_status, _status, null)

func _on_next_name_pressed() -> void:
	Audio.click()
	_sign_up_name.text = _gename.next()

func _on_remember_pressed() -> void:
	ConnectStore.data.all.remember = _sign_in_remember.pressed
	ConnectStore.write()

func _clear_focus() -> void:
	var accept = _accept_stack[0]
	if accept != null: accept.shortcut = null
	var cancel = _cancel_stack[0]
	if cancel != null: cancel.shortcut = null

func _apply_focus() -> void:
	_focus_stack[0].grab_focus()
	var accept = _accept_stack[0]
	if accept != null: accept.shortcut = _accept
	var cancel = _cancel_stack[0]
	if cancel != null: cancel.shortcut = _cancel

func _pop_focus() -> void:
	_clear_focus()
	_focus_stack.pop_front()
	_accept_stack.pop_front()
	_cancel_stack.pop_front()
	_apply_focus()

func _push_focus(focus: Control, accept: Control, cancel: Control):
	_clear_focus()
	_focus_stack.push_front(focus)
	_accept_stack.push_front(accept)
	_cancel_stack.push_front(cancel)
	_apply_focus()

func _focus(focus: Control, accept: Control, cancel: Control):
	_clear_focus()
	_focus_stack[0] = focus
	_accept_stack[0] = accept
	_cancel_stack[0] = cancel
	_apply_focus()

func _show_error(error: String) -> void:
	Audio.error()
	_message_close.grab_focus()
	_message_title.text = "Error"
	_message_text.text = error
	_spring(_message_anchor, _dialog, false)
	_push_focus(_message_close, _message_close, _message_close)

func _on_close_error_pressed() -> void:
	Audio.click()
	_spring(_message_anchor_back, _dialog)
	_pop_focus()

func _spring(a := _anchor, c := _interface, click := true) -> void:
	if click: Audio.click()
	var tween = create_tween()
	tween.set_trans(_trans).set_ease(_ease)
	tween.tween_property(c, "anchor_left", a.position.x, _time)
	tween.parallel().tween_property(c, "anchor_top", a.position.y, _time)
	tween.parallel().tween_property(c, "anchor_right", a.size.x, _time)
	tween.parallel().tween_property(c, "anchor_bottom", a.size.y, _time)

func _spring_status(click := true) -> void:
	_focus(_status, _status, null)
	_spring(_anchor, _interface, click)

func _spring_sign_in(click := true) -> void:
	_focus(_sign_in_email, _sign_in_sign_in, _sign_in_close)
	_spring(_sign_in_anchor, _interface, click)

func _spring_sign_up() -> void:
	_focus(_sign_up_email, _sign_up_sign_up, _sign_up_close)
	_spring(_sign_up_anchor)

func _spring_reset() -> void:
	_focus(_reset_email, _reset_reset, _reset_close)
	_spring(_reset_anchor)

func _spring_account(click := true) -> void:
	_focus(_account_sign_out, _account_sign_out, _account_close)
	_spring(_account_anchor, _interface, click)

func _spring_email() -> void:
	_focus(_email_email, _email_change, _email_close)
	_spring(_email_anchor)

func _spring_password() -> void:
	_focus(_password_password, _password_change, _password_close)
	_spring(_password_anchor)

func _valid_email(text: String) -> bool: return _regex.search(text) != null

# firebase requires 3 nakama requires 8
func _valid_password(text: String) -> bool: return text.length() > 7

func _error_clear(controls: Array) -> void:
	for i in range(controls.size()):
		controls[i].modulate = Color.WHITE

func _error_set(control: Control) -> void:
	Audio.error()
	control.modulate = _disconnected_color

func _disable_input(controls: Array) -> void:
	_enable_wait()
	for control in controls:
		control.disabled = true

func _enable_input(controls: Array) -> void:
	_disable_wait()
	for control in controls:
		control.disabled = false

func _enable_wait() -> void: Cursor.wait = true

func _disable_wait() -> void: Cursor.wait = false
