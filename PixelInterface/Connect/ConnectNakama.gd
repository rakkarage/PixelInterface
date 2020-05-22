extends Connect

onready var _client := Nakama.create_client("defaultkey", "127.0.0.1", 7350, "http")
var _session: NakamaSession
var _gename = Gename.new()

func authenticated() -> bool:
	return _session != null and _session.valid and not _session.expired

func _ready() -> void:
	if _signInRemember.pressed:
		_session = NakamaClient.restore_session(Store.data.nakama.token)

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
		_loadDoc()

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
		var remember = Store.data.connect.remember
		Store.data.nakama.token = _session.token if remember else ""
		Store.data.connect.email = email if remember else ""
		Store.write()
		_updateStatus()
		_springStatus(false)

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
		Store.data.connect.email = email if Store.data.connect.remember else ""
		Store.write()
		_springSignIn(false)

### account

func _onSignOutPressed() -> void:
	_clickAudio.play()
	_session = null
	Store.data.nakama.token = ""
	Store.data.connect.email = ""
	Store.write()
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
		return
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
		return
	_successAudio.play()
	_passwordPassword.text = ""
	_passwordConfirm.text = ""
	_updateStatus()
	_springAccount(false)

### data

const _collection = "docs"
const _key = "doc"
var _docVersion := "*"
const _docDefault := {
	"title": "",
	"number": "",
	"text": ""
}
var _doc := _docDefault.duplicate()

func _setDoc(value: Dictionary):
	_doc = value.duplicate()
	_dataTitle.text = _doc.title
	_dataNumber.value = int(_doc.number)
	_dataText.text = _doc.text

func _loadDoc() -> void:
	_disableInput([_dataSave, _dataDelete])
	var result : NakamaAPI.ApiStorageObjects = yield(_client.read_storage_objects_async(_session, [
		NakamaStorageObjectId.new(_collection, _key, _session.user_id),
	]), "completed")
	_enableInput([_dataSave, _dataDelete])
	if result.is_exception():
		_showError(result.get_exception().message)
		return
	var doc = result.objects[0]
	_docVersion = doc.version
	_doc = JSON.parse(doc.value).result
	_dataTitle.text = _doc.title
	_dataNumber.value = int(_doc.number)
	_dataText.text = _doc.text
	_successAudio.play()

func _onSaveDocPressed() -> void:
	_clickAudio.play()
	_doc.title = _dataTitle.text
	_doc.number = str(_dataNumber.value)
	_doc.text = _dataText.text
	_disableInput([_dataSave, _dataDelete])
	var result : NakamaAPI.ApiStorageObjectAcks = yield(_client.write_storage_objects_async(_session, [
		NakamaWriteStorageObject.new(_collection, _key, true, true, JSON.print(_doc), _docVersion),
	]), "completed")
	_enableInput([_dataSave, _dataDelete])
	if result.is_exception():
		_showError(result.get_exception().message)
		return
	_successAudio.play()

func _onDeleteDocPressed() -> void:
	_clickAudio.play()
	_disableInput([_dataSave, _dataDelete])
	var result : NakamaAsyncResult = yield(_client.delete_storage_objects_async(_session, [
		NakamaStorageObjectId.new(_collection, _key, _session.user_id, _docVersion)
	]), "completed")
	_enableInput([_dataSave, _dataDelete])
	if result.is_exception():
		_showError(result.get_exception().message)
		return
	_dataTitle.text = ""
	_dataNumber.value = 0
	_dataText.text = ""
	_successAudio.play()
