extends Connect

var _expires := 0
var _expiresOffset := 120

func _ready() -> void:
	super._ready()

	var remember = Store.data.all.remember
	_signInRemember.button_pressed = remember
	if remember:
		_signInEmail.text = Store.data.f.email
	await _onRefreshToken()
	await _lookup()

	# firebase: no password for change email!?
	_emailPassword.editable = false

func authenticated() -> bool:
	return not _accountEmail.text.is_empty()

func _extractName(result: Dictionary) -> String:
	return result.displayName if "displayName" in result else result.users[0].displayName if "users" in result else ""

func _extractEmail(result: Dictionary) -> String:
	return result.email if "email" in result else result.users[0].email if "users" in result else Store.data.f.email

func _extractToken(result: Dictionary) -> String:
	return result.idToken if "idToken" in result else result.id_token if "id_token" in result else Store.data.f.token

func _extractRefresh(result: Dictionary) -> String:
	return result.refreshToken if "refreshToken" in result else result.refresh_token if "refresh_token" in result else Store.data.f.refresh

func _extractId(result: Dictionary) -> String:
	return result.localId if "localId" in result else result.users[0].localId if "users" in result else Store.data.f.id

func _onAuthChanged(response: Array) -> void:
	await get_tree().process_frame
	if response.size() > 0 and response[1] == 200:
		var result = _getResult(response)
		var email = _extractEmail(result)
		Store.data.f.token = _extractToken(result)
		Store.data.f.email = email if Store.data.all.remember else ""
		Store.data.f.refresh = _extractRefresh(result)
		Store.data.f.id = _extractId(result)
		if "expiresIn" in result:
			_expires = int(result.expiresIn)
		elif "expires_in" in result:
			_expires = int(result.expires_in)
		_status.modulate = _connectedColor
		_statusEmail.text = email
		_accountEmail.text = email
		_accountName.text = _extractName(result)
		_dataSave.disabled = false
		_dataDelete.disabled = false
		await _loadDoc()
	else:
		Store.data.f.token = ""
		Store.data.f.email = ""
		Store.data.f.refresh = ""
		Store.data.f.id = ""
		_status.modulate = _disconnectedColor
		_statusEmail.text = "Welcome."
		_accountEmail.text = ""
		_accountName.text = ""
		_dataSave.disabled = true
		_dataDelete.disabled = true
		_clearDoc()
	Store.write()
	if _expires > 0:
		var timer = get_tree().create_timer(_expires - _expiresOffset)
		await timer.timeout
		timer.start()
		_expires = 0

func _getResult(response: Array) -> Dictionary:
	return JSON.parse_string(response[3].get_string_from_utf8()).result

func _handleError(result: Dictionary) -> void:
	_showError(result.error.message.capitalize())

### status

func _onStatusPressed() -> void:
	if authenticated():
		_springAccount()
	else:
		_springSignIn()

func _lookup() -> void:
	var response = await Firebase.lookup(_http, Store.data.f.token)
	await _onAuthChanged(response)

func _onRefreshToken() -> void:
	var response = await Firebase.refresh(_http, Store.data.f.refresh)
	await _onAuthChanged(response)

### signIn

func _onSignInPressed() -> void:
	_clickAudio.play()
	var email = _signInEmail.text
	var password = _signInPassword.text
	_errorClear([_signInEmail, _signInPassword])
	if email.is_empty() or not _validEmail(email):
		_errorSet(_signInEmail)
		return
	if password.is_empty() or not _validPassword(password):
		_errorSet(_signInPassword)
		return
	_disableInput([_signInSignIn])
	var response = await Firebase.signIn(_http, email, password)
	_enableInput([_signInSignIn])
	var result = _getResult(response)
	if response[1] == 200:
		_successAudio.play()
		_signInPassword.text = ""
		_springStatus(false)
	else:
		_handleError(result)
		_signUpEmail.text = _signInEmail.text
		_resetEmail.text = _signInEmail.text
	await _onAuthChanged(response)

### signUp

func _onSignUpPressed() -> void:
	_clickAudio.play()
	var email = _signUpEmail.text
	var password = _signUpPassword.text
	var confirm = _signUpConfirm.text
	_errorClear([_signUpEmail, _signUpPassword, _signUpConfirm])
	if email.is_empty() or not _validEmail(email):
		_errorSet(_signUpEmail)
		return
	if password.is_empty() or not _validPassword(password):
		_errorSet(_signUpPassword)
		return
	if confirm != password:
		_errorSet(_signUpConfirm)
		return
	_disableInput([_signUpSignUp])
	var response = await Firebase.signUp(_http, email, password)
	_enableInput([_signUpSignUp])
	var result = _getResult(response)
	if response[1] == 200:
		_successAudio.play()
		_signUpName.text = _gename.next()
		_signUpEmail.text = ""
		_signUpPassword.text = ""
		_signUpConfirm.text = ""
		_springStatus(false)
		var text = _signUpName.text
		if text != "":
			await _changeName(result.idToken, text)
	else:
		_handleError(result)
	await _onAuthChanged(response)

### change name

func _changeName(token: String, text: String) -> void:
	var response = await Firebase.changeName(_http, token, text)
	await _onAuthChanged(response)

### reset password

func _onResetPressed() -> void:
	_clickAudio.play()
	var email = _resetEmail.text
	_errorClear([_resetEmail])
	if email.is_empty() or not _validEmail(email):
		_errorSet(_resetEmail)
		return
	_disableInput([_resetReset])
	var response = await Firebase.reset(_http, _resetEmail.text)
	_enableInput([_resetReset])
	if response[1] == 200:
		_successAudio.play()
		_resetEmail.text = ""
		_springSignIn(false)
	else:
		_handleError(_getResult(response))

### account

func _onSignOutPressed() -> void:
	_clickAudio.play()
	_disableInput([_accountSignOut])
	await _onAuthChanged([])
	_enableInput([_accountSignOut])
	_clearDoc()
	_successAudio.play()
	_springStatus()

### change email

func _onChangeEmailPressed() -> void:
	_clickAudio.play()
	var email = _emailEmail.text
	var confirm = _emailConfirm.text
	_errorClear([_emailEmail, _emailConfirm])
	if email.is_empty() or not _validEmail(email):
		_errorSet(_emailEmail)
		return
	if confirm != email:
		_errorSet(_emailConfirm)
		return
	_disableInput([_emailChange])
	var response = await Firebase.changeEmail(_http, Store.data.f.token, email)
	_enableInput([_emailChange])
	var result = _getResult(response)
	if response[1] == 200:
		_successAudio.play()
		_emailEmail.text = ""
		_emailConfirm.text = ""
		_springAccount(false)
	else:
		_handleError(result)
	await _onAuthChanged(response)

### change password

func _onChangePasswordPressed() -> void:
	_clickAudio.play()
	var password = _passwordPassword.text
	var confirm = _passwordConfirm.text
	_errorClear([_passwordPassword, _passwordConfirm])
	if password.is_empty() or not _validPassword(password):
		_errorSet(_passwordPassword)
		return
	if confirm != password:
		_errorSet(_passwordConfirm)
		return
	_disableInput([_passwordChange])
	var response = await Firebase.changePassword(_http, Store.data.f.token, password)
	_enableInput([_passwordChange])
	var result = _getResult(response)
	if response[1] == 200:
		_successAudio.play()
		_passwordPassword.text = ""
		_passwordConfirm.text = ""
		_springAccount(false)
	else:
		_handleError(result)
	await _onAuthChanged(response)

### data

var _docExists := true
const _docDefault := {
	"title": { "stringValue": "" },
	"number": { "integerValue": "" },
	"text": { "stringValue": "" }
}
var _doc = _docDefault.duplicate()

func _setDoc(value: Dictionary) -> void:
	_doc = value.duplicate()
	_dataTitle.text = _doc.title.stringValue
	_dataNumber.value = int(_doc.number.integerValue)
	_dataText.text = _doc.text.stringValue

func _clearDoc() -> void:
	_setDoc(_docDefault.duplicate())

func _docChanged(response: Array) -> void:
	_setDoc(_docDefault)
	if response[1] == 404:
		_docExists = false
	if response[1] == 200:
		var result = _getResult(response)
		if result.size() > 0 and "fields" in result:
			_setDoc(result.fields)

func _loadDoc() -> void:
	_disableInput([_dataSave, _dataDelete])
	var response = await Firebase.loadDoc(_http, Store.data.f.token, Store.data.f.id)
	_enableInput([_dataSave, _dataDelete])
	_docChanged(response)

func _onSaveDocPressed() -> void:
	_clickAudio.play()
	_doc.title.stringValue = _dataTitle.text
	_doc.number.integerValue = str(_dataNumber.value)
	_doc.text.stringValue = _dataText.text
	_disableInput([_dataSave, _dataDelete])
	var response
	if _docExists:
		response = await Firebase.updateDoc(_http, Store.data.f.token, Store.data.f.id, _doc)
	else:
		response = await Firebase.saveDoc(_http, Store.data.f.token, Store.data.f.id, _doc)
	_enableInput([_dataSave, _dataDelete])
	_docChanged(response)

func _onDeleteDocPressed() -> void:
	_clickAudio.play()
	_disableInput([_dataSave, _dataDelete])
	var response = await Firebase.deleteDoc(_http, Store.data.f.token, Store.data.f.id)
	_enableInput([_dataSave, _dataDelete])
	_docChanged(response)
