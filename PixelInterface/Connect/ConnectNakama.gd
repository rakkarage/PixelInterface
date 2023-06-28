extends Connect

@onready var _client := Nakama.create_client("defaultkey", "127.0.0.1", 7350, "http")
var _session: NakamaSession

func _ready() -> void:
	super._ready()
	_sign_in_remember.button_pressed = ConnectStore.data.all.remember
	if ConnectStore.data.all.remember:
		_sign_in_email.text = ConnectStore.data.n.email
		_session = NakamaClient.restore_session(ConnectStore.data.n.token)
	_update_status()
	_status.grab_focus()
	# nakama: no password reset!?
	_sign_in_reset.disabled = true

func authenticated() -> bool:
	return _session != null and _session.valid and not _session.expired

### status

func _on_status_pressed() -> void:
	if authenticated():
		_spring_account()
	else:
		_spring_sign_in()

func _update_status() -> void:
	var account : NakamaAPI.ApiAccount = null
	if _session != null:
		_disable_input([_status])
		account = await _client.get_account_async(_session)
		_enable_input([_status])
	if account == null or account.is_exception() or account.email.is_empty():
		_status.modulate = _disconnected_color
		_status_email.text = "Welcome."
		_account_email.text = ""
		_account_name.text = _gename.next()
		_data_save.disabled = true
		_data_delete.disabled = true
	else:
		_status.modulate = _connected_color
		_status_email.text = account.email
		_account_email.text = account.email
		_account_name.text = _session.username
		_data_save.disabled = false
		_data_delete.disabled = false
		_load_doc()

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
	_session = await _client.authenticate_email_async(email, password, null, false)
	_enable_input([_sign_in_sign_in])
	if _session.is_exception():
		_show_error(_session.get_exception().message)
		_sign_up_email.text = _sign_in_email.text
		_reset_email.text = _sign_in_email.text
	elif _session.valid and not _session.expired:
		Audio.success()
		_sign_in_password.text = ""
		var remember = ConnectStore.data.all.remember
		ConnectStore.data.n.token = _session.token if remember else ""
		ConnectStore.data.n.email = email if remember else ""
		ConnectStore.write()
		_update_status()
		_spring_status(false)

### signUp

func _on_sign_up_pressed() -> void:
	Audio.click()
	var n = _sign_up_name.text
	var e = _sign_up_email.text
	var p = _sign_up_password.text
	var c = _sign_up_confirm.text
	_error_clear([_sign_up_email, _sign_up_password, _sign_up_confirm])
	if e.is_empty() or not _valid_email(e):
		_error_set(_sign_up_email)
		return
	if p.is_empty() or not _valid_password(p):
		_error_set(_sign_up_password)
		return
	if c != p:
		_error_set(_sign_up_confirm)
		return
	_disable_input([_sign_up_sign_up])
	_session = await _client.authenticate_email_async(e, p, n, true)
	_enable_input([_sign_up_sign_up])
	if _session.is_exception():
		_show_error(_session.get_exception().message)
	elif _session.valid and not _session.expired:
		Audio.success()
		_sign_in_email.text = _sign_up_email.text
		_sign_up_name.text = _gename.next()
		_sign_up_email.text = ""
		_sign_up_password.text = ""
		_sign_up_confirm.text = ""
		ConnectStore.data.n.email = e if ConnectStore.data.all.remember else ""
		ConnectStore.write()
		_update_status()
		_spring_status(false)

### account

func _on_sign_out_pressed() -> void:
	Audio.click()
	_session = null
	ConnectStore.data.n.token = ""
	ConnectStore.data.n.email = ""
	ConnectStore.write()
	_clear_doc()
	Audio.success()
	_update_status()
	_spring_status()

### change email

func _on_change_email_pressed() -> void:
	Audio.click()
	var password = _email_password.text
	var email = _email_email.text
	var confirm = _email_confirm.text
	_error_clear([_email_password, _email_email, _email_confirm])
	if password.is_empty() or not _valid_password(password):
		_error_set(_email_password)
		return
	if email.is_empty() or not _valid_email(email):
		_error_set(_email_email)
		return
	if confirm != email:
		_error_set(_email_confirm)
		return
	_disable_input([_email_change])
	var result = await _client.link_email_async(_session, email, password)
	_enable_input([_email_change])
	if result.is_exception():
		_show_error(result.get_exception().message)
		return
	Audio.success()
	_email_password.text = ""
	_email_email.text = ""
	_email_confirm.text = ""
	_update_status()
	_spring_account(false)

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
	var result = await _client.link_email_async(_session, _status_email.text, password)
	_enable_input([_password_change])
	if result.is_exception():
		_show_error(result.get_exception().message)
		return
	Audio.success()
	_password_password.text = ""
	_password_confirm.text = ""
	_update_status()
	_spring_account(false)

### data

const _collection = "docs"
const _key = "doc"
var _doc_version := "*"
const _doc_default := {
	"title": "",
	"number": "",
	"text": ""
}
var _doc := _doc_default.duplicate()

func _set_doc(value: Dictionary) -> void:
	_doc = value.duplicate()
	_data_title.text = _doc.title
	_data_number.value = int(_doc.number)
	_data_text.text = _doc.text

func _clear_doc() -> void:
	_set_doc(_doc_default.duplicate())

func _load_doc() -> void:
	_disable_input([_data_save, _data_delete])
	var result : NakamaAPI.ApiStorageObjects = await _client.read_storage_objects_async(_session, [
		NakamaStorageObjectId.new(_collection, _key, _session.user_id),
	])
	_enable_input([_data_save, _data_delete])
	if result.is_exception():
		_show_error(result.get_exception().message)
		return
	if result.objects.size() > 0:
		var doc = result.objects[0]
		_doc_version = doc.version
		_doc = JSON.parse_string(doc.value).result
		_data_title.text = _doc.title
		_data_number.value = int(_doc.number)
		_data_text.text = _doc.text
		Audio.success()

func _on_save_doc_pressed() -> void:
	Audio.click()
	_doc.title = _data_title.text
	_doc.number = str(_data_number.value)
	_doc.text = _data_text.text
	_disable_input([_data_save, _data_delete])
	var result : NakamaAPI.ApiStorageObjectAcks = await _client.write_storage_objects_async(_session, [
		NakamaWriteStorageObject.new(_collection, _key, true, true, JSON.stringify(_doc), _doc_version),
	])
	_enable_input([_data_save, _data_delete])
	if result.is_exception():
		_show_error(result.get_exception().message)
		return
	Audio.success()

func _on_delete_doc_pressed() -> void:
	Audio.click()
	_disable_input([_data_save, _data_delete])
	var result : NakamaAsyncResult = await _client.delete_storage_objects_async(_session, [
		NakamaStorageObjectId.new(_collection, _key, _session.user_id, _doc_version)
	])
	_enable_input([_data_save, _data_delete])
	if result.is_exception():
		_show_error(result.get_exception().message)
		return
	_data_title.text = ""
	_data_number.value = 0
	_data_text.text = ""
	Audio.success()
