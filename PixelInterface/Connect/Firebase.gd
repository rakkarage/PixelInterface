extends Node

const _signInUrl := "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=%s"
const _signUpUrl := "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=%s"
const _resetUrl := "https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=%s"
const _getUserUrl := "https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=%s"
const _setUserUrl := "https://identitytoolkit.googleapis.com/v1/accounts:update?key=%s"
const _projectId := "godotconnect"
const _docsUrl := "https://firestore.googleapis.com/v1/projects/%s/databases/(default)/documents/" % _projectId
var _apiKey := ""
const _stateDefault := {
	"token": "",
	"id": "",
	"email": ""
}
var _state := {}
func _setState(value: Dictionary):
	_state.token = value.token
	_state.id = value.id
	_state.email = value.email
const _tokenPath := "user://token.txt"
var _f := File.new()
var _d := Directory.new()

signal signedIn(response)
signal signedUp(response)
signal signedOut()
signal reset(response)
signal changedEmail(response)
signal changedPassword(response)
signal lookup()
signal docChanged(response)

func _ready() -> void:
	Utility.ok(_f.open("res://PixelInterface/Connect/apikey.txt", File.READ))
	_apiKey = _f.get_as_text()
	_f.close()
	_setState(_stateDefault)

func tokenSave() -> void:
	if not _state.token.empty():
		Utility.ok(_f.open(_tokenPath, File.WRITE))
		_f.store_string(_state.token)
		_f.close()

func tokenLoad() -> void:
	if _f.file_exists(_tokenPath):
		Utility.ok(_f.open(_tokenPath, File.READ))
		_state.token = _f.get_as_text()
		_f.close()

func tokenClear() -> void:
	if _f.file_exists(_tokenPath):
		Utility.ok(_d.remove(_tokenPath))

func _formState(response: Array, id: String = "") -> Dictionary:
	var o = JSON.parse(response[3].get_string_from_ascii()).result as Dictionary
	return {
		"token": o.idToken if id.empty() else _state.token,
		"id": o.localId if "localId" in o else o.users[0].localId if "users" in o else _state.id,
		"email": o.users[0].email if "users" in o else _state.email
	}

func signIn(http: HTTPRequest, email: String, password: String) -> void:
	var body := { "email": email, "password": password, "returnSecureToken": true }
	Utility.ok(http.request(_signInUrl % _apiKey, [], false, HTTPClient.METHOD_POST, to_json(body)))
	var response = yield(http, "request_completed")
	if response[1] == 200:
		_setState(_formState(response))
	emit_signal("signedIn", response)

func signUp(http: HTTPRequest, email : String, password : String) -> void:
	var body := { "email": email, "password": password }
	Utility.ok(http.request(_signUpUrl % _apiKey, [], false, HTTPClient.METHOD_POST, to_json(body)))
	var response = yield(http, "request_completed")
	emit_signal("signedUp", response)

func reset(http: HTTPRequest, email: String) -> void:
	var body := { "requestType": "PASSWORD_RESET", "email": email }
	Utility.ok(http.request(_resetUrl % _apiKey, [], false, HTTPClient.METHOD_POST, to_json(body)))
	var response = yield(http, "request_completed")
	emit_signal("reset", response)

func signOut() -> void:
	tokenClear()
	_setState(_stateDefault)
	emit_signal("signedOut")

func changeEmail(http: HTTPRequest, email: String) -> void:
	var body := { "idToken": _state.token, "email": email, "returnSecureToken": true }
	Utility.ok(http.request(_setUserUrl % _apiKey, [], false, HTTPClient.METHOD_POST, to_json(body)))
	var response = yield(http, "request_completed")
	if response[1] == 200:
		_setState(_formState(response))
	emit_signal("changedEmail", response)

func changePassword(http: HTTPRequest, password: String) -> void:
	var body := { "idToken": _state.token, "password": password, "returnSecureToken": true }
	Utility.ok(http.request(_setUserUrl % _apiKey, [], false, HTTPClient.METHOD_POST, to_json(body)))
	var response = yield(http, "request_completed")
	if response[1] == 200:
		_setState(_formState(response))
	emit_signal("changedPassword", response)

func lookup(http: HTTPRequest) -> void:
	var body := { "idToken": _state.token }
	Utility.ok(http.request(_getUserUrl % _apiKey, [], false, HTTPClient.METHOD_POST, to_json(body)))
	var response = yield(http, "request_completed")
	if response[1] == 200:
		_setState(_formState(response, _state.token))
	emit_signal("lookup", _state.email)

func authenticated() -> bool:
	return not _state.token.empty()

func _formHeaders() -> PoolStringArray:
	return PoolStringArray([
		"Content-Type: application/json",
		"Authorization: Bearer " + _state.token
	])

func saveDoc(http: HTTPRequest, path: String, fields: Dictionary) -> void:
	var body := { "fields": fields }
	Utility.ok(http.request(_docsUrl + path % _state.id, _formHeaders(), false, HTTPClient.METHOD_POST, to_json(body)))
	var response = yield(http, "request_completed")
	emit_signal("docChanged", response)

func loadDoc(http: HTTPRequest, path: String) -> void:
	Utility.ok(http.request(_docsUrl + path % _state.id, _formHeaders(), false, HTTPClient.METHOD_GET))
	var response = yield(http, "request_completed")
	emit_signal("docChanged", response)

func updateDoc(http: HTTPRequest, path: String, fields: Dictionary) -> void:
	var body := { "fields": fields }
	Utility.ok(http.request(_docsUrl + path % _state.id, _formHeaders(), false, HTTPClient.METHOD_PATCH, to_json(body)))
	var response = yield(http, "request_completed")
	emit_signal("docChanged", response)

func deleteDoc(http: HTTPRequest, path: String) -> void:
	Utility.ok(http.request(_docsUrl + path % _state.id, _formHeaders(), false, HTTPClient.METHOD_DELETE))
	var response = yield(http, "request_completed")
	emit_signal("docChanged", response)
