extends Connect

onready var _client := Nakama.create_client("defaultkey", "127.0.0.1", 7350, "http")
var _session: NakamaSession

const _section = "nakama"
const _key = "session"

func _ready() -> void:
	var token = Store.getValue(_section, _key, "")
	var session = NakamaClient.restore_session(token)
	if session.valid and not session.expired:
		_session = session
		return
	var deviceId = OS.get_unique_id()
	_session = yield(_client.authenticate_device_async(deviceId), "completed")
	if not _session.is_exception():
		Store.setValue(_section, _key, _session.token)
	print(session)

### status

func _onStatusPressed() -> void:
	# if not Firebase.authenticated():
		_springSignIn()
	# else:
	# 	_springAccount()

func _updateStatus() -> void:
	# Firebase.lookup(_http)
	pass

func _onUpdatedStatus(email: String) -> void:
	if email.empty():
		_status.modulate = _disconnectedColor
		_statusEmail.text = "Welcome."
		_accountEmail.text = ""
		_dataSave.disabled = true
		_dataDelete.disabled = true
	else:
		_status.modulate = _connectedColor
		_statusEmail.text = email
		_accountEmail.text = email
		_dataSave.disabled = false
		_dataDelete.disabled = false
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
	_session = yield(_client.authenticate_email_async(email, password), "completed")
	print(_session)

func _onSignedIn(response: Array) -> void:
	if response[1] == 200:
		_successAudio.play()
		_signInPassword.text = ""
		_updateStatus()
		_springStatus(false)
		# if _signInRemember.pressed:
		# 	Firebase.tokenSave()
		# else:
		# 	Firebase.tokenClear()
	else:
#		_handleError(response)
		_resetEmail.text = _signInEmail.text
	_enableInput([_signInSignIn])
