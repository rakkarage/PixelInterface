extends Connect

onready var _client := Nakama.create_client("defaultkey", "127.0.0.1", 7350, "http")
var _session: NakamaSession

const _section = "nakama"
const _key = "session"
func SetValue(value: String) -> void: Store.setValue(_section, _key, value)
func GetValue() -> String: return Store.getValue(_section, _key)
func ClearValue() -> void: Store.clearValue(_section, _key)

func authenticated() -> bool:
	return _session == null or _session.created == false or _session.email == ""

func _ready() -> void:
	if _signInRemember.pressed:
		var session = NakamaClient.restore_session(GetValue())
		if session.valid and not session.expired:
			_session = session
			return
		var deviceId = OS.get_unique_id()
		_disableInput([_status])
		_session = yield(_client.authenticate_device_async(deviceId), "completed")
		_enableInput([_status])
		if not _session.is_exception():
			SetValue(_session.token)

	_updateStatus()
	_status.grab_focus()

### status

func _onStatusPressed() -> void:
	if authenticated():
		_springSignIn()
	else:
		_springAccount()

func _updateStatus() -> void:
	_disableInput([_status])
	var account : NakamaAPI.ApiAccount = yield(_client.get_account_async(_session), "completed")
	_enableInput([_status])
	if account.is_exception():
		print("Exception: " + account.to_string())
		return
	var email = account.email
	if email.empty():
		_status.modulate = _disconnectedColor
		_statusEmail.text = "Welcome."
		_accountEmail.text = ""
	else:
		_status.modulate = _connectedColor
		_statusEmail.text = email
		_accountEmail.text = email
	# _loadDoc()

### signIn

func _onSignInPressed() -> void:
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
	_disableInput([_signInSignIn])
	_session = yield(_client.authenticate_email_async(email, password, null, false), "completed")
	_enableInput([_signInSignIn])
	if _session.is_exception():
		_showError(_session.message.to_string())
		_resetEmail.text = _signInEmail.text
	elif _session.valid and not _session.expired:
		_successAudio.play()
		_signInPassword.text = ""
		_updateStatus()
		_springStatus(false)
		if _signInRemember.pressed:
			SetValue(_session.token)
		else:
			ClearValue()

### signUp

func _onSignUpPressed() -> void:
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
	_disableInput([_signUpSignUp])
	_session = yield(_client.authenticate_email_async(email, password, null, true), "completed")
	_enableInput([_signUpSignUp])
	if _session.is_exception():
		_showError(_session.message.to_string())
	elif _session.valid and not _session.expired:
		_successAudio.play()
		_signInEmail.text = _signUpEmail.text
		_signUpEmail.text = ""
		_signUpPassword.text = ""
		_signUpConfirm.text = ""
		_springSignIn(false)
