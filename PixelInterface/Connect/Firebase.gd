extends Node

const _signInUrl := "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=%s"
const _signUpUrl := "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=%s"
const _resetUrl := "https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=%s"
const _getUserUrl := "https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=%s"
const _setUserUrl := "https://identitytoolkit.googleapis.com/v1/accounts:update?key=%s"
const _refreshUrl := "https://securetoken.googleapis.com/v1/token?key=%s"
const _docsProject := "godotconnect"
const _docsCollection := "users"
const _docsUrl := "https://firestore.googleapis.com/v1/projects/%s/databases/(default)/documents/" % _docsProject
var _apiKey := ""

func _ready() -> void:
	var file := File.new()
	assert(file.open("res://PixelInterface/Connect/apikey.txt", File.READ) == OK)
	_apiKey = file.get_as_text()
	file.close()

func signIn(http: HTTPRequest, email: String, password: String) -> Array:
	var body := { "email": email, "password": password, "returnSecureToken": true }
	assert(http.request(_signInUrl % _apiKey, [], false, HTTPClient.METHOD_POST, to_json(body)) == OK)
	return yield(http, "request_completed")

func signUp(http: HTTPRequest, email : String, password : String) -> Array:
	var body := { "email": email, "password": password }
	assert(http.request(_signUpUrl % _apiKey, [], false, HTTPClient.METHOD_POST, to_json(body)) == OK)
	return yield(http, "request_completed")

func reset(http: HTTPRequest, email: String) -> Array:
	var body := { "requestType": "PASSWORD_RESET", "email": email }
	assert(http.request(_resetUrl % _apiKey, [], false, HTTPClient.METHOD_POST, to_json(body)) == OK)
	return yield(http, "request_completed")

func changeEmail(http: HTTPRequest, token: String, email: String) -> void:
	var body := { "idToken": token, "email": email, "returnSecureToken": true }
	assert(http.request(_setUserUrl % _apiKey, [], false, HTTPClient.METHOD_POST, to_json(body)) == OK)
	return yield(http, "request_completed")

func changePassword(http: HTTPRequest, token: String, password: String) -> void:
	var body := { "idToken": token, "password": password, "returnSecureToken": true }
	assert(http.request(_setUserUrl % _apiKey, [], false, HTTPClient.METHOD_POST, to_json(body)) == OK)
	return yield(http, "request_completed")

func changeName(http: HTTPRequest, token: String, name: String) -> void:
	var body := { "idToken": token, "displayName": name, "returnSecureToken": true }
	assert(http.request(_setUserUrl % _apiKey, [], false, HTTPClient.METHOD_POST, to_json(body)) == OK)
	return yield(http, "request_completed")

func lookup(http: HTTPRequest, token: String) -> void:
	var body := { "idToken": token }
	assert(http.request(_getUserUrl % _apiKey, [], false, HTTPClient.METHOD_POST, to_json(body)) == OK)
	return yield(http, "request_completed")

func refresh(http: HTTPRequest, refresh: String) -> void:
	var query := "grant_type=refresh_token&refresh_token=%s" % refresh
	assert(http.request(_refreshUrl % _apiKey, ["Content-Type: application/x-www-form-urlencoded"], true, HTTPClient.METHOD_POST, query) == OK)
	return yield(http, "request_completed")

func _headers(token: String) -> PoolStringArray:
	return PoolStringArray(["Content-Type: application/json", "Authorization: Bearer " + token])

func loadDoc(http: HTTPRequest, token: String, id: String) -> void:
	assert(http.request(_docsUrl + "%s/%s" % [_docsCollection, id], _headers(token), false, HTTPClient.METHOD_GET) == OK)
	return yield(http, "request_completed")

func saveDoc(http: HTTPRequest, token: String, id: String, fields: Dictionary) -> void:
	var body := to_json({ "fields": fields })
	assert(http.request(_docsUrl + "%s?documentId=%s" % [_docsCollection, id], _headers(token), false, HTTPClient.METHOD_POST, body) == OK)
	return yield(http, "request_completed")

func updateDoc(http: HTTPRequest, token: String, id: String, fields: Dictionary) -> void:
	var body := to_json({ "fields": fields })
	assert(http.request(_docsUrl + "%s/%s" % [_docsCollection, id], _headers(token), false, HTTPClient.METHOD_PATCH, body) == OK)
	return yield(http, "request_completed")

func deleteDoc(http: HTTPRequest, token: String, id: String) -> void:
	assert(http.request(_docsUrl + "%s/%s" % [_docsCollection, id], _headers(token), false, HTTPClient.METHOD_DELETE) == OK)
	return yield(http, "request_completed")
