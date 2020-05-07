extends Node

const _signInUrl := "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=%s"
const _signUpUrl := "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=%s"
const _resetUrl := "https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=%s"
const _getUserUrl := "https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=%s"
const _setUserUrl := "https://identitytoolkit.googleapis.com/v1/accounts:update?key=%s"
var _apiKey := ""
var _token := ""
var _f := File.new()
const _statePath := "user://state.txt"

signal signedIn(response)
signal signedUp(response)
signal signedOut()
signal reset(response)
signal changedEmail(response)
signal changedPassword(response)
signal lookedUp(response)

func _ready() -> void:
	Utility.ok(_f.open("res://PixelInterface/Connect/apikey.txt", File.READ))
	_apiKey = _f.get_as_text()
	_f.close()
	_loadToken()

func _saveToken() -> void:
	if not _token.empty():
		Utility.ok(_f.open(_statePath, File.WRITE))
		_f.store_string(_token)
		_f.close()

func _loadToken() -> void:
	if _f.file_exists(_statePath):
		Utility.ok(_f.open(_statePath, File.READ))
		_token = _f.get_as_text()
		_f.close()

func _getToken(response: Array) -> String:
	var o = JSON.parse(response[3].get_string_from_ascii()).result as Dictionary
	return o.idToken

func _getEmail(response: Array) -> String:
	var o = JSON.parse(response[3].get_string_from_ascii()).result as Dictionary
	return o.users[0].email

func signIn(http: HTTPRequest, email: String, password: String) -> void:
	var body := { "email": email, "password": password }
	Utility.ok(http.request(_signInUrl % _apiKey, [], false, HTTPClient.METHOD_POST, to_json(body)))
	var response = yield(http, "request_completed")
	if response[1] == 200:
		_token = _getToken(response)
		_saveToken()
	emit_signal("signedIn", response)

func signUp(http: HTTPRequest, email : String, password : String) -> void:
	var body := { "email": email, "password": password }
	Utility.ok(http.request(_signUpUrl % _apiKey, [], false, HTTPClient.METHOD_POST, to_json(body)))
	var response = yield(http, "request_completed")
	if response[1] == 200: _token = _getToken(response)
	emit_signal("signedUp", response)

func reset(http: HTTPRequest, email: String) -> void:
	var body := { "requestType": "PASSWORD_RESET", "email": email }
	Utility.ok(http.request(_resetUrl % _apiKey, [], false, HTTPClient.METHOD_POST, to_json(body)))
	var response = yield(http, "request_completed")
	emit_signal("reset", response)

func signOut() -> void:
	_token = ""
	emit_signal("signedOut")

func changeEmail(http: HTTPRequest, email: String) -> void:
	var body := { "idToken": _token, "email": email, "returnSecureToken": true }
	Utility.ok(http.request(_setUserUrl % _apiKey, [], false, HTTPClient.METHOD_POST, to_json(body)))
	var response = yield(http, "request_completed")
	if response[1] == 200:
		_token = _getToken(response)
		_saveToken()
	emit_signal("changedEmail", response)

func changePassword(http: HTTPRequest, password: String) -> void:
	var body := { "idToken": _token, "password": password, "returnSecureToken": true }
	Utility.ok(http.request(_setUserUrl % _apiKey, [], false, HTTPClient.METHOD_POST, to_json(body)))
	var response = yield(http, "request_completed")
	if response[1] == 200:
		_token = _getToken(response)
		_saveToken()
	emit_signal("changedPassword", response)

func lookup(http: HTTPRequest) -> void:
	var body := { "idToken": _token }
	Utility.ok(http.request(_getUserUrl % _apiKey, [], false, HTTPClient.METHOD_POST, to_json(body)))
	var response = yield(http, "request_completed")
	emit_signal("lookedUp", _getEmail(response) if response[1] == 200 else "")

func authenticated() -> bool:
	return not _token.empty()
