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

	if _f.file_exists(_rememberPath):
		Utility.ok(_f.open(_rememberPath, File.READ))
		_signInRemember.pressed = bool(_f.get_8())
		_f.close()

	if _signInRemember.pressed:
		Firebase.tokenLoad()

	_updateStatus()
	_status.grab_focus()

func _focus(focus: Control, accept: Control, cancel: Control):
	focus.grab_focus()
	if _currentAccept != null:
		_currentAccept.shortcut = null
	if accept != null:
		_currentAccept = accept
		_currentAccept.shortcut = _accept
	if _currentCancel != null:
		_currentCancel.shortcut = null
	if cancel != null:
		_currentCancel = cancel
		_currentCancel.shortcut = _cancel

### status

func _springStatus(click := true) -> void:
	if click: _clickAudio.play()
	_focus(_status, _status, null)
	_spring()

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

func _springSignIn(click := true) -> void:
	if click: _clickAudio.play()
	_focus(_signInEmail, _signInSignIn, _signInClose)
	_spring(_signInAnchor)

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

func _springSignUp() -> void:
	_clickAudio.play()
	_focus(_signUpEmail, _signUpSignUp, _signUpClose)
	_spring(_signUpAnchor)

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

func _springReset() -> void:
	_clickAudio.play()
	_focus(_resetEmail, _resetReset, _resetClose)
	_spring(_resetAnchor)

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

func _springAccount(click := true) -> void:
	if click: _clickAudio.play()
	_focus(_accountSignOut, _accountSignOut, _accountClose)
	_spring(_accountAnchor)

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

func _springEmail() -> void:
	_clickAudio.play()
	_focus(_emailEmail, _emailChange, _emailClose)
	_spring(_emailAnchor)

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

func _springPassword() -> void:
	_clickAudio.play()
	_focus(_passwordPassword, _passwordChange, _passwordClose)
	_spring(_passwordAnchor)

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

### dialog

func _showError(response: Array) -> void:
	_errorAudio.play()
	_messageClose.grab_focus()
	_messageTitle.text = "Error"
	var o = JSON.parse(response[3].get_string_from_ascii()).result
	_messageText.text = o.error.message.capitalize()
	_spring(_messageAnchor, _dialog)

func _hideError() -> void:
	_clickAudio.play()
	_spring(_anchor, _dialog)

func _spring(a := _anchor, c := _interface) -> void:
	_tween.interpolate_property(c, "anchor_left", null, a.position.x, _time, _trans, _ease)
	_tween.interpolate_property(c, "anchor_top", null, a.position.y, _time, _trans, _ease)
	_tween.interpolate_property(c, "anchor_right", null, a.size.x, _time, _trans, _ease)
	_tween.interpolate_property(c, "anchor_bottom", null, a.size.y, _time, _trans, _ease)
	_tween.start()

func _validEmail(text: String) -> bool: return _regex.search(text) != null

func _validPassword(text: String) -> bool: return text.length() > 2

func _errorClear(controls: Array) -> void:
	for i in range(controls.size()):
		controls[i].modulate = Color.white

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
