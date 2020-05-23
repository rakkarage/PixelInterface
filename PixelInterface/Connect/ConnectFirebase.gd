extends Connect

var _session: Dictionary

func _ready() -> void:
	_signInRemember.pressed = Store.data.all.remember
	if Store.data.all.remember:
		_signInEmail.text = Store.data.f.email

	_updateStatus(Store.data.f.token)
	_status.grab_focus()

	# firebase: no password for change email!?
	_emailPassword.editable = false

func authenticated() -> bool:
	return not _accountEmail.text.empty()

func _setData(result: Dictionary = {}) -> void:
	if result.size() == 0:
		Store.data.f.token = ""
		Store.data.f.email = ""
		Store.data.f.id = ""
	else:
		if "users" in result:
			Store.data.f.email = result.users[0].email if Store.data.all.remember else ""
			Store.data.f.id = result.users[0].localId
		else:
			Store.data.f.token = result.idToken
			Store.data.f.email = result.email if Store.data.all.remember else ""
			Store.data.f.id = result.localId
	Store.write()

### status

func _onStatusPressed() -> void:
	if authenticated():
		_springAccount()
	else:
		_springSignIn()

func _updateStatus(token: String) -> void:
	var response = yield(Firebase.lookup(_http, token), "completed")
	var result = _getResult(response)
	if response[1] == 200:
		_setData(result)
		var email = Store.data.f.email
		_status.modulate = _connectedColor
		_statusEmail.text = email
		_accountEmail.text = email
		_accountName.text = result.displayName if "displayName" in result else result.users[0].displayName if "users" in result else ""
		_dataSave.disabled = false
		_dataDelete.disabled = false
		_loadDoc()
	else:
		_setData()
		_status.modulate = _disconnectedColor
		_statusEmail.text = "Welcome."
		_accountEmail.text = ""
		_dataTitle.text = ""
		_dataNumber.value = 0
		_dataText.text = ""
		_dataSave.disabled = true
		_dataDelete.disabled = true

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
	var response = yield(Firebase.signIn(_http, email, password), "completed")
	_enableInput([_signInSignIn])
	var result = _getResult(response)
	if response[1] == 200:
		_successAudio.play()
		_signInPassword.text = ""
		_setData(result)
		_updateStatus(result.idToken)
		_springStatus(false)
	else:
		_handleError(result)
		_signUpEmail.text = _signInEmail.text
		_resetEmail.text = _signInEmail.text

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
	var response = yield(Firebase.signUp(_http, email, password), "completed")
	_enableInput([_signUpSignUp])
	var result = _getResult(response)
	if response[1] == 200:
		var name = _signUpName.text
		if name != "":
			_changeName(result.idToken, name)
		_successAudio.play()
		_signInEmail.text = _signUpEmail.text
		_signUpName.text = _gename.next()
		_signUpEmail.text = ""
		_signUpPassword.text = ""
		_signUpConfirm.text = ""
		_springSignIn(false)
	else:
		_handleError(result)

### change name

func _changeName(token: String, name: String) -> void:
	var response = yield(Firebase.changeName(_http, token, name), "completed")
	_accountName.text = _getResult(response).displayName if response[1] == 200 else ""

### reset password

func _onResetPressed() -> void:
	_clickAudio.play()
	var email = _resetEmail.text
	_errorClear([_resetEmail])
	if email.empty() or not _validEmail(email):
		_errorSet(_resetEmail)
		return
	_disableInput([_resetReset])
	var response = yield(Firebase.reset(_http, _resetEmail.text), "completed")
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
	_updateStatus("")
	_enableInput([_accountSignOut])
	_successAudio.play()
	_springStatus()

### change email

func _onChangeEmailPressed() -> void:
	_clickAudio.play()
	var email = _emailEmail.text
	var confirm = _emailConfirm.text
	_errorClear([_emailEmail, _emailConfirm])
	if email.empty() or not _validEmail(email):
		_errorSet(_emailEmail)
		return
	if confirm != email:
		_errorSet(_emailConfirm)
		return
	_disableInput([_emailChange])
	var response = yield(Firebase.changeEmail(_http, Store.data.f.token, email), "completed")
	_enableInput([_emailChange])
	var result = _getResult(response)
	if response[1] == 200:
		_successAudio.play()
		_emailEmail.text = ""
		_emailConfirm.text = ""
		_setData(result)
		_updateStatus(result.idToken)
		_springAccount(false)
	else:
		_handleError(result)

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
	var response = yield(Firebase.changePassword(_http, Store.data.f.token, password), "completed")
	_enableInput([_passwordChange])
	var result = _getResult(response)
	if response[1] == 200:
		_successAudio.play()
		_passwordPassword.text = ""
		_passwordConfirm.text = ""
		_setData(result)
		_updateStatus(result.idToken)
		_springAccount(false)
	else:
		_handleError(result)

### data

var _docExists := true
const _docDefault := {
	"title": { "stringValue": "" },
	"number": { "integerValue": "" },
	"text": { "stringValue": "" }
}
var _doc = _docDefault.duplicate()

func _setDoc(value: Dictionary):
	_doc = value.duplicate()
	_dataTitle.text = _doc.title.stringValue
	_dataNumber.value = int(_doc.number.integerValue)
	_dataText.text = _doc.text.stringValue

func _handleDoc(response: Array):
	_setDoc(_docDefault)
	if response[1] == 404:
		_docExists = false
	if response[1] == 200:
		_successAudio.play()
		_setDoc(_getResult(response).fields)

func _loadDoc() -> void:
	_disableInput([_dataSave, _dataDelete])
	var response = yield (Firebase.loadDoc(_http, Store.data.f.token, "users/%s" % Store.data.f.id), "completed")
	_enableInput([_dataSave, _dataDelete])
	_handleDoc(response)

func _onSaveDocPressed() -> void:
	_clickAudio.play()
	_doc.title.stringValue = _dataTitle.text
	_doc.number.integerValue = str(_dataNumber.value)
	_doc.text.stringValue = _dataText.text
	_disableInput([_dataSave, _dataDelete])
	var response
	if _docExists:
		response = yield(Firebase.updateDoc(_http, Store.data.f.token, "users/%s" % Store.data.f.id, _doc), "completed")
	else:
		response = yield(Firebase.saveDoc(_http, Store.data.f.token, "users?documentId=%s" % Store.data.f.id, _doc), "completed")
	_enableInput([_dataSave, _dataDelete])
	_handleDoc(response)

func _onDeleteDocPressed() -> void:
	_clickAudio.play()
	_disableInput([_dataSave, _dataDelete])
	var response = yield(Firebase.deleteDoc(_http, Store.data.f.token, "users/%s" % Store.data.f.id), "completed")
	_enableInput([_dataSave, _dataDelete])
	_handleDoc(response)

func _getResult(response: Array) -> Dictionary:
	return JSON.parse(response[3].get_string_from_ascii()).result

func _handleError(result: Dictionary) -> void:
	_showError(result.error.message.capitalize())
