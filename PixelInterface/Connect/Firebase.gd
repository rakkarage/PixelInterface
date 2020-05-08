extends Node

const _signInUrl := "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=%s"
const _signUpUrl := "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=%s"
const _resetUrl := "https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=%s"
const _getUserUrl := "https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=%s"
const _setUserUrl := "https://identitytoolkit.googleapis.com/v1/accounts:update?key=%s"
const _projectId := "godotconnect"
const _docsUrl := "https://firestore.googleapis.com/v1/projects/%s/databases/(default)/documents/" % _projectId
var _apiKey := ""
var _state := {
	"token": "",
	"id": "",
	"email": ""
}
const _statePath := "user://state.txt"
var _f := File.new()

signal signedIn(response)
signal signedUp(response)
signal signedOut()
signal reset(response)
signal changedEmail(response)
signal changedPassword(response)
signal lookup()
signal docChanged()

func _ready() -> void:
	Utility.ok(_f.open("res://PixelInterface/Connect/apikey.txt", File.READ))
	_apiKey = _f.get_as_text()
	_f.close()
	_loadToken()

func _saveToken() -> void:
	if not _state.token.empty():
		Utility.ok(_f.open(_statePath, File.WRITE))
		_f.store_string(_state.token)
		_f.close()

func _loadToken() -> void:
	if _f.file_exists(_statePath):
		Utility.ok(_f.open(_statePath, File.READ))
		_state.token = _f.get_as_text()
		_f.close()

func _getState(response: Array, id: String = "") -> Dictionary:
	print(response)
	var o = JSON.parse(response[3].get_string_from_ascii()).result as Dictionary
	print(o)
	return {
		"token": o.idToken if id.empty() else id,
		"id": o.localId if "localId" in o else "",
		"email": o.users[0].email
	}

func _getHeaders() -> PoolStringArray:
	return PoolStringArray([
		"Content-Type: application/json",
		"Authorization: Bearer %s" % _state.token
	])

func signIn(http: HTTPRequest, email: String, password: String) -> void:
	var body := { "email": email, "password": password }
	Utility.ok(http.request(_signInUrl % _apiKey, [], false, HTTPClient.METHOD_POST, to_json(body)))
	var response = yield(http, "request_completed")
	if response[1] == 200:
		_state = _getState(response)
		_saveToken()
	emit_signal("signedIn", response)

func signUp(http: HTTPRequest, email : String, password : String) -> void:
	var body := { "email": email, "password": password }
	Utility.ok(http.request(_signUpUrl % _apiKey, [], false, HTTPClient.METHOD_POST, to_json(body)))
	var response = yield(http, "request_completed")
	# if response[1] == 200:
	# 	_state = _getState(response)
	emit_signal("signedUp", response)

func reset(http: HTTPRequest, email: String) -> void:
	var body := { "requestType": "PASSWORD_RESET", "email": email }
	Utility.ok(http.request(_resetUrl % _apiKey, [], false, HTTPClient.METHOD_POST, to_json(body)))
	var response = yield(http, "request_completed")
	emit_signal("reset", response)

func signOut() -> void:
	_state = {}
	emit_signal("signedOut")

func changeEmail(http: HTTPRequest, email: String) -> void:
	var body := { "idToken": _state.token, "email": email, "returnSecureToken": true }
	Utility.ok(http.request(_setUserUrl % _apiKey, [], false, HTTPClient.METHOD_POST, to_json(body)))
	var response = yield(http, "request_completed")
	if response[1] == 200:
		_state = _getState(response)
		_saveToken()
	emit_signal("changedEmail", response)

func changePassword(http: HTTPRequest, password: String) -> void:
	var body := { "idToken": _state.token, "password": password, "returnSecureToken": true }
	Utility.ok(http.request(_setUserUrl % _apiKey, [], false, HTTPClient.METHOD_POST, to_json(body)))
	var response = yield(http, "request_completed")
	if response[1] == 200:
		_state = _getState(response)
		_saveToken()
	emit_signal("changedPassword", response)

func lookup(http: HTTPRequest) -> void:
	var body := { "idToken": _state.token }
	Utility.ok(http.request(_getUserUrl % _apiKey, [], false, HTTPClient.METHOD_POST, to_json(body)))
	var response = yield(http, "request_completed")
	if response[1] == 200:
		print(response)
		_state = _getState(response, _state.token)
	emit_signal("lookup")

func authenticated() -> bool:
	return not _state.token.empty()

func saveDoc(path: String, fields: Dictionary, http: HTTPRequest) -> void:
	var body := { "fields": fields }
	Utility.ok(http.request(_docsUrl + path, _getHeaders(), false, HTTPClient.METHOD_POST, to_json(body)))
	var response = yield(http, "request_completed")
	emit_signal("docChanged", response)

func loadDoc(path: String, http: HTTPRequest) -> void:
	Utility.ok(http.request(_docsUrl + path, _getHeaders(), false, HTTPClient.METHOD_GET))
	var response = yield(http, "request_completed")
	emit_signal("docChanged", response)

func updateDoc(path: String, fields: Dictionary, http: HTTPRequest) -> void:
	var body := { "fields": fields }
	Utility.ok(http.request(_docsUrl + path, _getHeaders(), false, HTTPClient.METHOD_PATCH, to_json(body)))
	var response = yield(http, "request_completed")
	emit_signal("docChanged", response)

func deleteDoc(path: String, http: HTTPRequest) -> void:
	Utility.ok(http.request(_docsUrl + path, _getHeaders(), false, HTTPClient.METHOD_DELETE))
	var response = yield(http, "request_completed")
	emit_signal("docChanged", response)
