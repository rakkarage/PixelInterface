extends Node

const _signInUrl := "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=%s"
const _signUpUrl := "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=%s"
const _resetUrl := "https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=%s"
const _getUserUrl := "https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=%s"
const _setUserUrl := "https://identitytoolkit.googleapis.com/v1/accounts:update?key=%s"
var _apiKey := ""
var _token := ""

signal signedIn(response)
signal signedUp(response)
signal signedOut()
signal reset()
signal emailChanged(response)
signal passwordChanged(response)

func _ready() -> void:
	var f = File.new()
	f.open("res://PixelInterface/Connect/apikey.txt", File.READ)
	_apiKey = f.get_as_text()
	f.close()

func _getToken(response: Array) -> String:
	var o = JSON.parse(response[3].get_string_from_ascii()).result as Dictionary
	return o.idToken

func signIn(http: HTTPRequest, email: String, password: String) -> void:
	var body := { "email": email, "password": password }
	Utility.ok(http.request(_signInUrl % _apiKey, [], false, HTTPClient.METHOD_POST, to_json(body)))
	var response = yield(http, "request_completed")
	if response[1] == 200:
		_token = _getToken(response)
	emit_signal("signedIn", response)

func signUp(http: HTTPRequest, email : String, password : String) -> void:
	var body := { "email": email, "password": password }
	Utility.ok(http.request(_signUpUrl % _apiKey, [], false, HTTPClient.METHOD_POST, to_json(body)))
	var response = yield(http, "request_completed")
	if response[1] == 200:
		_token = _getToken(response)
	emit_signal("signedUp", response)

func reset(http: HTTPRequest, email: String) -> void:
	var body := { "requestType": "PASSWORD_RESET", "email": email }
	Utility.ok(http.request(_resetUrl % _apiKey, [], false, HTTPClient.METHOD_POST, to_json(body)))
	yield(http, "request_completed")
	emit_signal("reset")

func signOut() -> void:
	_token = ""
	emit_signal("signedOut")

func changeEmail(http: HTTPRequest, email: String) -> void:
	var body := { "idToken": _token, "email": email, "returnSecureToken": true }
	Utility.ok(http.request(_setUserUrl % _apiKey, [], false, HTTPClient.METHOD_POST, to_json(body)))
	var response = yield(http, "request_completed")
	if response[1] == 200:
		_token = _getToken(response)
	emit_signal("emailChanged", response)

func changePassword(http: HTTPRequest, password: String) -> void:
	var body := { "idToken": _token, "password": password, "returnSecureToken": true }
	Utility.ok(http.request(_setUserUrl % _apiKey, [], false, HTTPClient.METHOD_POST, to_json(body)))
	var response = yield(http, "request_completed")
	if response[1] == 200:
		_token = _getToken(response)
	emit_signal("passwordChanged", response)

func authenticated() -> bool:
	return not _token.empty()
