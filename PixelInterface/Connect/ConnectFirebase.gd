extends Connect

var _expires := 0
var _expiresOffset := 120

func _ready() -> void:
	super._ready()

	var remember = Store.data.all.remember
	_sign_in_remember.button_pressed = remember
	if remember:
		_sign_in_email.text = Store.data.f.email
	await _on_refresh_token()
	await _lookup()

	# firebase: no password for change email!?
	_email_password.editable = false

func authenticated() -> bool:
	return not _account_email.text.is_empty()

func _extract_name(result: Dictionary) -> String:
	return result.displayName if "displayName" in result else result.users[0].displayName if "users" in result else ""

func _extract_email(result: Dictionary) -> String:
	return result.email if "email" in result else result.users[0].email if "users" in result else Store.data.f.email

func _extract_token(result: Dictionary) -> String:
	return result.idToken if "idToken" in result else result.id_token if "id_token" in result else Store.data.f.token

func _extract_refresh(result: Dictionary) -> String:
	return result.refreshToken if "refreshToken" in result else result.refresh_token if "refresh_token" in result else Store.data.f.refresh

func _extract_id(result: Dictionary) -> String:
	return result.localId if "localId" in result else result.users[0].localId if "users" in result else Store.data.f.id

func _on_auth_changed(response: Array) -> void:
	await get_tree().process_frame
	if response.size() > 0 and response[1] == 200:
		var result = _get_result(response)
		var email = _extract_email(result)
		Store.data.f.token = _extract_token(result)
		Store.data.f.email = email if Store.data.all.remember else ""
		Store.data.f.refresh = _extract_refresh(result)
		Store.data.f.id = _extract_id(result)
		if "expiresIn" in result:
			_expires = int(result.expiresIn)
		elif "expires_in" in result:
			_expires = int(result.expires_in)
		_status.modulate = _connected_color
		_status_email.text = email
		_account_email.text = email
		_account_name.text = _extract_name(result)
		_data_save.disabled = false
		_data_delete.disabled = false
		await _load_doc()
	else:
		Store.data.f.token = ""
		Store.data.f.email = ""
		Store.data.f.refresh = ""
		Store.data.f.id = ""
		_status.modulate = _disconnected_color
		_status_email.text = "Welcome."
		_account_email.text = ""
		_account_name.text = ""
		_data_save.disabled = true
		_data_delete.disabled = true
		_clear_doc()
	Store.write()
	if _expires > 0:
		var timer = get_tree().create_timer(_expires - _expiresOffset)
		await timer.timeout
		timer.start()
		_expires = 0

func _get_result(response: Array) -> Dictionary:
	return JSON.parse_string(response[3].get_string_from_utf8()).result

func _handle_error(result: Dictionary) -> void:
	_show_error(result.error.message.capitalize())

### status

func _on_status_pressed() -> void:
	if authenticated():
		_spring_account()
	else:
		_spring_sign_in()

func _lookup() -> void:
	var response = await Firebase.lookup(_http, Store.data.f.token)
	await _on_auth_changed(response)

func _on_refresh_token() -> void:
	var response = await Firebase.refresh(_http, Store.data.f.refresh)
	await _on_auth_changed(response)

### signIn

func _on_sign_in_pressed() -> void:
	Audio.click()
	var email = _sign_in_email.text
	var password = _sign_in_password.text
	_error_clear([_sign_in_email, _sign_in_password])
	if email.is_empty() or not _valid_email(email):
		_error_set(_sign_in_email)
		return
	if password.is_empty() or not _valid_password(password):
		_error_set(_sign_in_password)
		return
	_disable_input([_sign_in_sign_in])
	var response = await Firebase.sign_in(_http, email, password)
	_enable_input([_sign_in_sign_in])
	var result = _get_result(response)
	if response[1] == 200:
		Audio.success()
		_sign_in_password.text = ""
		_spring_status(false)
	else:
		_handle_error(result)
		_sign_up_email.text = _sign_in_email.text
		_reset_email.text = _sign_in_email.text
	await _on_auth_changed(response)

### signUp

func _on_sign_up_pressed() -> void:
	Audio.click()
	var email = _sign_up_email.text
	var password = _sign_up_password.text
	var confirm = _sign_up_confirm.text
	_error_clear([_sign_up_email, _sign_up_password, _sign_up_confirm])
	if email.is_empty() or not _valid_email(email):
		_error_set(_sign_up_email)
		return
	if password.is_empty() or not _valid_password(password):
		_error_set(_sign_up_password)
		return
	if confirm != password:
		_error_set(_sign_up_confirm)
		return
	_disable_input([_sign_up_sign_up])
	var response = await Firebase.sign_up(_http, email, password)
	_enable_input([_sign_up_sign_up])
	var result = _get_result(response)
	if response[1] == 200:
		Audio.success()
		_sign_up_name.text = _gename.next()
		_sign_up_email.text = ""
		_sign_up_password.text = ""
		_sign_up_confirm.text = ""
		_spring_status(false)
		var text = _sign_up_name.text
		if text != "":
			await _change_name(result.idToken, text)
	else:
		_handle_error(result)
	await _on_auth_changed(response)

### change name

func _change_name(token: String, text: String) -> void:
	var response = await Firebase.change_name(_http, token, text)
	await _on_auth_changed(response)

### reset password

func _on_reset_pressed() -> void:
	Audio.click()
	var email = _reset_email.text
	_error_clear([_reset_email])
	if email.is_empty() or not _valid_email(email):
		_error_set(_reset_email)
		return
	_disable_input([_reset_reset])
	var response = await Firebase.reset(_http, _reset_email.text)
	_enable_input([_reset_reset])
	if response[1] == 200:
		Audio.success()
		_reset_email.text = ""
		_spring_sign_in(false)
	else:
		_handle_error(_get_result(response))

### account

func _on_sign_out_pressed() -> void:
	Audio.click()
	_disable_input([_account_sign_out])
	await _on_auth_changed([])
	_enable_input([_account_sign_out])
	_clear_doc()
	Audio.success()
	_spring_status()

### change email

func _on_change_email_pressed() -> void:
	Audio.click()
	var email = _email_email.text
	var confirm = _email_confirm.text
	_error_clear([_email_email, _email_confirm])
	if email.is_empty() or not _valid_email(email):
		_error_set(_email_email)
		return
	if confirm != email:
		_error_set(_email_confirm)
		return
	_disable_input([_email_change])
	var response = await Firebase.change_email(_http, Store.data.f.token, email)
	_enable_input([_email_change])
	var result = _get_result(response)
	if response[1] == 200:
		Audio.success()
		_email_email.text = ""
		_email_confirm.text = ""
		_spring_account(false)
	else:
		_handle_error(result)
	await _on_auth_changed(response)

### change password

func _on_change_password_pressed() -> void:
	Audio.click()
	var password = _password_password.text
	var confirm = _password_confirm.text
	_error_clear([_password_password, _password_confirm])
	if password.is_empty() or not _valid_password(password):
		_error_set(_password_password)
		return
	if confirm != password:
		_error_set(_password_confirm)
		return
	_disable_input([_password_change])
	var response = await Firebase.change_password(_http, Store.data.f.token, password)
	_enable_input([_password_change])
	var result = _get_result(response)
	if response[1] == 200:
		Audio.success()
		_password_password.text = ""
		_password_confirm.text = ""
		_spring_account(false)
	else:
		_handle_error(result)
	await _on_auth_changed(response)

### data

var _doc_exists := true
const _doc_default := {
	"title": { "value": "" },
	"number": { "value": 0 },
	"text": { "value": "" }
}
var _doc = _doc_default.duplicate()

func _set_doc(value: Dictionary) -> void:
	_doc = value.duplicate()
	_data_title.text = _doc.title.value
	_data_number.value = int(_doc.number.value)
	_data_text.text = _doc.text.value

func _clear_doc() -> void:
	_set_doc(_doc_default.duplicate())

func _doc_changed(response: Array) -> void:
	_set_doc(_doc_default)
	if response[1] == 404:
		_doc_exists = false
	if response[1] == 200:
		var result = _get_result(response)
		if result.size() > 0 and "fields" in result:
			_set_doc(result.fields)

func _load_doc() -> void:
	_disable_input([_data_save, _data_delete])
	var response = await Firebase.load_doc(_http, Store.data.f.token, Store.data.f.id)
	_enable_input([_data_save, _data_delete])
	_doc_changed(response)

func _on_save_doc_pressed() -> void:
	Audio.click()
	_doc.title.value = _data_title.text
	_doc.number.value = str(_data_number.value)
	_doc.text.value = _data_text.text
	_disable_input([_data_save, _data_delete])
	var response
	if _doc_exists:
		response = await Firebase.update_doc(_http, Store.data.f.token, Store.data.f.id, _doc)
	else:
		response = await Firebase.save_doc(_http, Store.data.f.token, Store.data.f.id, _doc)
	_enable_input([_data_save, _data_delete])
	_doc_changed(response)

func _on_delete_doc_pressed() -> void:
	Audio.click()
	_disable_input([_data_save, _data_delete])
	var response = await Firebase.delete_doc(_http, Store.data.f.token, Store.data.f.id)
	_enable_input([_data_save, _data_delete])
	_doc_changed(response)
