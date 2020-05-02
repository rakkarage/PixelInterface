extends Node

const lookup := "https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=%s"
const signInUrl := "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=%s"
const signUpUrl := "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=%s"
var apiKey := ""
var token := ""

signal signedIn(r)
signal signedUp(r)
signal signedOut()

func _ready() -> void:
	var f = File.new()
	f.open("res://PixelInterface/Dialog/Connect/apikey.txt", File.READ)
	apiKey = f.get_as_text()
	f.close()

func _getToken(response: Array) -> String:
	var json = JSON.parse(response[3].get_string_from_ascii()).result as Dictionary
	return json.idToken

func signIn(http: HTTPRequest, email : String, password : String) -> void:
	var body := { "email" : email, "password" : password }
	Utility.ok(http.request(signInUrl % apiKey, [], false, HTTPClient.METHOD_POST, to_json(body)))
	var response = yield(http, "request_completed")
	if response[1] == 200:
		token = _getToken(response)
	emit_signal("signedIn", response)

func signUp(http: HTTPRequest, email : String, password : String) -> void:
	var body := { "email" : email, "password" : password }
	Utility.ok(http.request(signUpUrl % apiKey, [], false, HTTPClient.METHOD_POST, to_json(body)))
	var response = yield(http, "request_completed")
	if response[1] == 200:
		token = _getToken(response)
	emit_signal("signedUp", response)

func signOut():
	token = ""
	emit_signal("signedOut")

func authenticated() -> bool:
	return not token.empty()