extends Connect

onready var _client := Nakama.create_client("defaultkey", "127.0.0.1", 7350, "http")
var _session: NakamaSession
var _store = Store.new("nakama", "session")
var _gename = Gename.new()

func authenticated() -> bool:
	return _session != null and _session.valid and not _session.expired

func _ready() -> void:
	if _signInRemember.pressed:
		_session = NakamaClient.restore_session(_store.data)

	_updateStatus()
	_status.grab_focus()

	_signUpName.text = _gename.next()

	# nakama: no password reset!?
	_signInReset.disabled = true

### status

func _onStatusPressed() -> void:
	if authenticated():
		_springAccount()
	else:
		_springSignIn()

func _updateStatus() -> void:
	var account : NakamaAPI.ApiAccount = null
	if _session != null:
		_disableInput([_status])
		account = yield(_client.get_account_async(_session), "completed")
		_enableInput([_status])
	if account == null or account.is_exception() or account.email.empty():
		_status.modulate = _disconnectedColor
		_statusEmail.text = "Welcome."
		_accountEmail.text = ""
	else:
		_status.modulate = _connectedColor
		_statusEmail.text = account.email
		_accountEmail.text = account.email
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
		_showError(_session.get_exception().message)
		_signUpEmail.text = _signInEmail.text
		_resetEmail.text = _signInEmail.text
	elif _session.valid and not _session.expired:
		_successAudio.play()
		_signInPassword.text = ""
		_updateStatus()
		_springStatus(false)
		if _signInRemember.pressed:
			_store.data = _session.token
		else:
			_store.clear()

### signUp

func _onSignUpNextPressed() -> void:
	_clickAudio.play()
	_signUpName.text = _gename.next()

func _onSignUpPressed() -> void:
	_clickAudio.play()
	var name = _signUpName.text
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
	_session = yield(_client.authenticate_email_async(email, password, name, true), "completed")
	_enableInput([_signUpSignUp])
	if _session.is_exception():
		_showError(_session.get_exception().message)
	elif _session.valid and not _session.expired:
		_successAudio.play()
		_signInEmail.text = _signUpEmail.text
		_signUpEmail.text = ""
		_signUpPassword.text = ""
		_signUpConfirm.text = ""
		_springSignIn(false)

### account

func _onSignOutPressed() -> void:
	_clickAudio.play()
	_store.clear()
	_session = null
	_successAudio.play()
	_updateStatus()
	_springStatus()

### change email

func _onChangeEmailPressed() -> void:
	_clickAudio.play()
	var password = _emailPassword.text
	var email = _emailEmail.text
	var confirm = _emailConfirm.text
	_errorClear([_emailPassword, _emailEmail, _emailConfirm])
	if password.empty() or not _validPassword(password):
		_errorSet(_emailPassword)
		return
	if email.empty() or not _validEmail(email):
		_errorSet(_emailEmail)
		return
	if confirm != email:
		_errorSet(_emailConfirm)
		return
	_disableInput([_emailChange])
	var result = yield(_client.link_email_async(_session, email, password), "completed")
	_enableInput([_emailChange])
	if result.is_exception():
		_showError(result.get_exception().message)
	else:
		_successAudio.play()
		_emailPassword.text = ""
		_emailEmail.text = ""
		_emailConfirm.text = ""
		_updateStatus()
		_springAccount(false)

### change password

func _onChangePasswordPressed() -> void:
	_clickAudio.play()
	var password = _passwordPassword.text
	var confirm = _passwordConfirm.text
	_errorClear([_passwordPassword, _passwordConfirm])
	if password.empty() or not _validPassword(password):
		_errorSet(_passwordPassword)
		return
	if confirm != password:
		_errorSet(_passwordConfirm)
		return
	_disableInput([_passwordChange])
	var result = yield(_client.link_email_async(_session, _statusEmail.text, password), "completed")
	_enableInput([_passwordChange])
	if result.is_exception():
		_showError(result.get_exception().message)
	else:
		_successAudio.play()
		_passwordPassword.text = ""
		_passwordConfirm.text = ""
		_updateStatus()
		_springAccount(false)
