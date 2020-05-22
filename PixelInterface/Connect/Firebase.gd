extends Node

const _signInUrl := "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=%s"
const _signUpUrl := "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=%s"
const _resetUrl := "https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=%s"
const _getUserUrl := "https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=%s"
const _setUserUrl := "https://identitytoolkit.googleapis.com/v1/accounts:update?key=%s"
const _projectId := "godotconnect"
const _docsUrl := "https://firestore.googleapis.com/v1/projects/%s/databases/(default)/documents/" % _projectId
var _apiKey := ""

signal signedIn(response)
signal signedUp(response)
signal reset(response)
signal changedName(response)
signal changedEmail(response)
signal changedPassword(response)
signal lookup(response)
signal docChanged(response)

func _ready() -> void:
	var file := File.new()
	Utility.ok(file.open("res://PixelInterface/Connect/apikey.txt", File.READ))
	_apiKey = file.get_as_text()
	file.close()

func signIn(http: HTTPRequest, email: String, password: String) -> void:
	var body := { "email": email, "password": password, "returnSecureToken": true }
	Utility.ok(http.request(_signInUrl % _apiKey, [], false, HTTPClient.METHOD_POST, to_json(body)))
	var response = yield(http, "request_completed")
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

func changeEmail(http: HTTPRequest, token: String, email: String) -> void:
	var body := { "idToken": token, "email": email, "returnSecureToken": true }
	Utility.ok(http.request(_setUserUrl % _apiKey, [], false, HTTPClient.METHOD_POST, to_json(body)))
	var response = yield(http, "request_completed")
	emit_signal("changedEmail", response)

func changePassword(http: HTTPRequest, token: String, password: String) -> void:
	var body := { "idToken": token, "password": password, "returnSecureToken": true }
	Utility.ok(http.request(_setUserUrl % _apiKey, [], false, HTTPClient.METHOD_POST, to_json(body)))
	var response = yield(http, "request_completed")
	emit_signal("changedPassword", response)

func changeName(http: HTTPRequest, token: String, name: String) -> void:
	var body := { "idToken": token, "displayName": name, "returnSecureToken": true }
	Utility.ok(http.request(_setUserUrl % _apiKey, [], false, HTTPClient.METHOD_POST, to_json(body)))
	var response = yield(http, "request_completed")
	emit_signal("changedName", response)

func lookup(http: HTTPRequest, token: String) -> void:
	var body := { "idToken": token }
	Utility.ok(http.request(_getUserUrl % _apiKey, [], false, HTTPClient.METHOD_POST, to_json(body)))
	var response = yield(http, "request_completed")
	emit_signal("lookup", response)

func authenticated() -> bool:
	return not Store.data.firebase.token.empty()

func _formHeaders() -> PoolStringArray:
	return PoolStringArray([
		"Content-Type: application/json",
		"Authorization: Bearer " + Store.data.firebase.token
	])

func saveDoc(http: HTTPRequest, path: String, id: String, fields: Dictionary) -> void:
	var body := to_json({ "fields": fields })
	Utility.ok(http.request(_docsUrl + path % id, _formHeaders(), false, HTTPClient.METHOD_POST, body))
	var response = yield(http, "request_completed")
	emit_signal("docChanged", response)

func loadDoc(http: HTTPRequest, path: String, id: String) -> void:
	Utility.ok(http.request(_docsUrl + path % id, _formHeaders(), false, HTTPClient.METHOD_GET))
	var response = yield(http, "request_completed")
	emit_signal("docChanged", response)

func updateDoc(http: HTTPRequest, path: String, id: String, fields: Dictionary) -> void:
	var body := to_json({ "fields": fields })
	Utility.ok(http.request(_docsUrl + path % id, _formHeaders(), false, HTTPClient.METHOD_PATCH, body))
	var response = yield(http, "request_completed")
	emit_signal("docChanged", response)

func deleteDoc(http: HTTPRequest, path: String, id: String) -> void:
	Utility.ok(http.request(_docsUrl + path % id, _formHeaders(), false, HTTPClient.METHOD_DELETE))
	var response = yield(http, "request_completed")
	emit_signal("docChanged", response)
