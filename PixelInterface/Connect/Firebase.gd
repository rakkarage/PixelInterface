extends Node

const _sign_in_url := "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=%s"
const _sign_up_url := "https://identitytoolkit.googleapis.com/v1/accounts:sign_up?key=%s"
const _reset_url := "https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=%s"
const _getUser_url := "https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=%s"
const _setUser_url := "https://identitytoolkit.googleapis.com/v1/accounts:update?key=%s"
const _refresh_url := "https://securetoken.googleapis.com/v1/token?key=%s"
const _docs_project := "godotconnect"
const _docs_collection := "users"
const _docs_url := "https://firestore.googleapis.com/v1/projects/%s/databases/(default)/documents/" % _docs_project
var _api_key := ""

func _ready() -> void:
	var file := FileAccess.open("res://PixelInterface/Connect/apiKey.txt", FileAccess.READ)
	if file:
		_api_key = file.get_as_text()
		file.close()

func sign_in(http: HTTPRequest, email: String, password: String):
	var body := { "email": email, "password": password, "returnSecureToken": true }
	http.request(_sign_in_url % _api_key, [], HTTPClient.METHOD_POST, JSON.stringify(body))
	return await http.request_completed

func sign_up(http: HTTPRequest, email : String, text : String):
	var body := { "email": email, "password": text }
	http.request(_sign_up_url % _api_key, [], HTTPClient.METHOD_POST, JSON.stringify(body))
	return await http.request_completed

func reset(http: HTTPRequest, email: String) -> Array:
	var body := { "requestType": "PASSWORD_RESET", "email": email }
	http.request(_reset_url % _api_key, [], HTTPClient.METHOD_POST, JSON.stringify(body))
	return await http.request_completed

func change_email(http: HTTPRequest, token: String, text: String):
	var body := { "idToken": token, "email": text, "returnSecureToken": true }
	http.request(_setUser_url % _api_key, [], HTTPClient.METHOD_POST, JSON.stringify(body))
	return await http.request_completed

func change_password(http: HTTPRequest, token: String, text: String):
	var body := { "idToken": token, "password": text, "returnSecureToken": true }
	http.request(_setUser_url % _api_key, [], HTTPClient.METHOD_POST, JSON.stringify(body))
	return await http.request_completed

func change_name(http: HTTPRequest, token: String, text: String):
	var body := { "idToken": token, "displayName": text, "returnSecureToken": true }
	http.request(_setUser_url % _api_key, [], HTTPClient.METHOD_POST, JSON.stringify(body))
	return await http.request_completed

func lookup(http: HTTPRequest, token: String):
	var body := { "idToken": token }
	http.request(_getUser_url % _api_key, [], HTTPClient.METHOD_POST, JSON.stringify(body))
	return await http.request_completed

func refresh(http: HTTPRequest, text: String):
	var query := "grant_type=refresh_token&refresh_token=%s" % text
	http.request(_refresh_url % _api_key, ["Content-Type: application/x-www-form-urlencoded"], HTTPClient.METHOD_POST, query)
	return await http.request_completed

func _headers(token: String) -> PackedStringArray:
	return PackedStringArray(["Content-Type: application/json", "Authorization: Bearer " + token])

func load_doc(http: HTTPRequest, token: String, id: String):
	http.request(_docs_url + "%s/%s" % [_docs_collection, id], _headers(token), HTTPClient.METHOD_GET)
	return await http.request_completed

func save_doc(http: HTTPRequest, token: String, id: String, fields: Dictionary):
	var body := JSON.stringify({ "fields": fields })
	http.request(_docs_url + "%s?documentId=%s" % [_docs_collection, id], _headers(token), HTTPClient.METHOD_POST, body)
	return await http.request_completed

func update_doc(http: HTTPRequest, token: String, id: String, fields: Dictionary):
	var body := JSON.stringify({ "fields": fields })
	http.request(_docs_url + "%s/%s" % [_docs_collection, id], _headers(token), HTTPClient.METHOD_PATCH, body)
	return await http.request_completed

func delete_doc(http: HTTPRequest, token: String, id: String):
	http.request(_docs_url + "%s/%s" % [_docs_collection, id], _headers(token), HTTPClient.METHOD_DELETE)
	return await http.request_completed
