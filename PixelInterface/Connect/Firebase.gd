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
	var file := FileAccess.open("res://PixelInterface/Connect/apiKey.txt", FileAccess.READ)
	if file:
		_apiKey = file.get_as_text()
		file.close()

func signIn(http: HTTPRequest, email: String, password: String):
	var body := { "email": email, "password": password, "returnSecureToken": true }
	http.request(_signInUrl % _apiKey, [], HTTPClient.METHOD_POST, JSON.stringify(body))
	return await http.request_completed

func signUp(http: HTTPRequest, email : String, text : String):
	var body := { "email": email, "password": text }
	http.request(_signUpUrl % _apiKey, [], HTTPClient.METHOD_POST, JSON.stringify(body))
	return await http.request_completed

func reset(http: HTTPRequest, email: String) -> Array:
	var body := { "requestType": "PASSWORD_RESET", "email": email }
	http.request(_resetUrl % _apiKey, [], HTTPClient.METHOD_POST, JSON.stringify(body))
	return await http.request_completed

func changeEmail(http: HTTPRequest, token: String, text: String):
	var body := { "idToken": token, "email": text, "returnSecureToken": true }
	http.request(_setUserUrl % _apiKey, [], HTTPClient.METHOD_POST, JSON.stringify(body))
	return await http.request_completed

func changePassword(http: HTTPRequest, token: String, text: String):
	var body := { "idToken": token, "password": text, "returnSecureToken": true }
	http.request(_setUserUrl % _apiKey, [], HTTPClient.METHOD_POST, JSON.stringify(body))
	return await http.request_completed

func changeName(http: HTTPRequest, token: String, text: String):
	var body := { "idToken": token, "displayName": text, "returnSecureToken": true }
	http.request(_setUserUrl % _apiKey, [], HTTPClient.METHOD_POST, JSON.stringify(body))
	return await http.request_completed

func lookup(http: HTTPRequest, token: String):
	var body := { "idToken": token }
	http.request(_getUserUrl % _apiKey, [], HTTPClient.METHOD_POST, JSON.stringify(body))
	return await http.request_completed

func refresh(http: HTTPRequest, text: String):
	var query := "grant_type=refresh_token&refresh_token=%s" % text
	http.request(_refreshUrl % _apiKey, ["Content-Type: application/x-www-form-urlencoded"], HTTPClient.METHOD_POST, query)
	return await http.request_completed

func _headers(token: String) -> PackedStringArray:
	return PackedStringArray(["Content-Type: application/json", "Authorization: Bearer " + token])

func loadDoc(http: HTTPRequest, token: String, id: String):
	http.request(_docsUrl + "%s/%s" % [_docsCollection, id], _headers(token), HTTPClient.METHOD_GET)
	return await http.request_completed

func saveDoc(http: HTTPRequest, token: String, id: String, fields: Dictionary):
	var body := JSON.stringify({ "fields": fields })
	http.request(_docsUrl + "%s?documentId=%s" % [_docsCollection, id], _headers(token), HTTPClient.METHOD_POST, body)
	return await http.request_completed

func updateDoc(http: HTTPRequest, token: String, id: String, fields: Dictionary):
	var body := JSON.stringify({ "fields": fields })
	http.request(_docsUrl + "%s/%s" % [_docsCollection, id], _headers(token), HTTPClient.METHOD_PATCH, body)
	return await http.request_completed

func deleteDoc(http: HTTPRequest, token: String, id: String):
	http.request(_docsUrl + "%s/%s" % [_docsCollection, id], _headers(token), HTTPClient.METHOD_DELETE)
	return await http.request_completed
