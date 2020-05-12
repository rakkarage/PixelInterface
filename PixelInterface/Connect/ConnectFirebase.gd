extends Connect

func _on_Remember_pressed() -> void:
	Utility.ok(_f.open(_rememberPath, File.WRITE))
	_f.store_8(_signInRemember.pressed)
	_f.close()

func _ready() -> void:
	Utility.ok(Firebase.connect("signedIn", self, "_onSignedIn"))
	Utility.ok(Firebase.connect("signedUp", self, "_onSignedUp"))
	Utility.ok(Firebase.connect("reset", self, "_onReset"))
	Utility.ok(Firebase.connect("signedOut", self, "_onSignedOut"))
	Utility.ok(Firebase.connect("changedEmail", self, "_onChangedEmail"))
	Utility.ok(Firebase.connect("changedPassword", self, "_onChangedPassword"))
	Utility.ok(Firebase.connect("lookup", self, "_onUpdatedStatus"))
	Utility.ok(Firebase.connect("docChanged", self, "_onDocChanged"))

	if _signInRemember.pressed:
		Firebase.tokenLoad()

	_updateStatus()
	_status.grab_focus()

### status

func _on_Status_pressed() -> void:
	if not Firebase.authenticated():
		_springSignIn()
	else:
		_springAccount()

func _updateStatus() -> void:
	Firebase.lookup(_http)

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
	_loadDoc()

### signIn

func _on_SignIn_pressed() -> void:
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
	Firebase.signIn(_http, email, password)

func _onSignedIn(response: Array) -> void:
	if response[1] == 200:
		_successAudio.play()
		_signInPassword.text = ""
		_updateStatus()
		_springStatus(false)
		if _signInRemember.pressed:
			Firebase.tokenSave()
		else:
			Firebase.tokenClear()
	else:
		_showError(response)
		_resetEmail.text = _signInEmail.text
	_enableInput([_signInSignIn])

### signUp

func _on_SignUp_pressed() -> void:
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
	Firebase.signUp(_http, email, password)

func _onSignedUp(response: Array) -> void:
	if response[1] == 200:
		_successAudio.play()
		_signInEmail.text = _signUpEmail.text
		_signUpEmail.text = ""
		_signUpPassword.text = ""
		_signUpConfirm.text = ""
		_springSignIn(false)
	else:
		_showError(response)
	_enableInput([_signUpSignUp])

### reset password

func _on_Reset_pressed() -> void:
	_clickAudio.play()
	var email = _resetEmail.text
	_errorClear([_resetEmail])
	if email.empty() or not _validEmail(email):
		_errorSet(_resetEmail)
		return
	_disableInput([_resetReset])
	Firebase.reset(_http, _resetEmail.text)

func _onReset(response: Array) -> void:
	if response[1] == 200:
		_successAudio.play()
		_resetEmail.text = ""
		_springSignIn(false)
	else:
		_showError(response)
	_enableInput([_resetReset])

### account

func _on_SignOut_pressed() -> void:
	_clickAudio.play()
	_disableInput([_accountSignOut])
	Firebase.signOut()

func _onSignedOut() -> void:
	_successAudio.play()
	_updateStatus()
	_springStatus()
	_enableInput([_accountSignOut])

### change email

func _on_ChangeEmail_pressed() -> void:
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
	Firebase.changeEmail(_http, email)

func _onChangedEmail(response: Array) -> void:
	if response[1] == 200:
		_successAudio.play()
		_emailEmail.text = ""
		_emailConfirm.text = ""
		Firebase.tokenSave()
		_updateStatus()
		_springAccount(false)
	else:
		_showError(response)
	_enableInput([_emailChange])

### change password

func _on_ChangePassword_pressed() -> void:
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
	Firebase.changePassword(_http, password)

func _onChangedPassword(response: Array) -> void:
	if response[1] == 200:
		_successAudio.play()
		_passwordPassword.text = ""
		_passwordConfirm.text = ""
		Firebase.tokenSave()
		_updateStatus()
		_springAccount(false)
	else:
		_showError(response)
	_enableInput([_passwordChange])

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

func _loadDoc() -> void:
	_disableInput([_dataSave, _dataDelete])
	Firebase.loadDoc(_http, "users/%s")

func _saveDoc() -> void:
	_clickAudio.play()
	_doc.title.stringValue = _dataTitle.text
	_doc.number.integerValue = str(_dataNumber.value)
	_doc.text.stringValue = _dataText.text
	_disableInput([_dataSave, _dataDelete])
	if _docExists:
		Firebase.updateDoc(_http, "users/%s", _doc)
	else:
		Firebase.saveDoc(_http, "users?documentId=%s", _doc)

func _deleteDoc() -> void:
	_clickAudio.play()
	_disableInput([_dataSave, _dataDelete])
	Firebase.deleteDoc(_http, "users/%s")

func _onDocChanged(response: Array) -> void:
	_setDoc(_docDefault)
	if response[1] == 404:
		_docExists = false
	if response[1] == 200:
		_successAudio.play()
		var o := JSON.parse(response[3].get_string_from_ascii()).result as Dictionary
		if "fields" in o:
			_setDoc(o.fields)
			_enableInput([_dataSave, _dataDelete])
	_disableWait()
