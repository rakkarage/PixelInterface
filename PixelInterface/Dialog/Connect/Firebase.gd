extends Node

const signInUrl := "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=%s"
const signUpUrl := "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=%s"
var apiKey := ""
var token := ""

func _ready() -> void:
	var file = File.new()
	file.open("res://PixelInterface/Dialog/Connect/apikey.txt", file.READ)
	apiKey = file.get_as_text()
	file.close()

func _getToken(response: Array) -> String:
	var json = JSON.parse(response[3].get_string_from_ascii()).result as Dictionary
	return json.idToken

func api(http: HTTPRequest, url: String = signUpUrl, email: String = "", password: String = "") -> void:
	var body := {
		"email" : email,
		"password" : password
	}
	Utility.ok(http.request(url % apiKey, [], false, HTTPClient.METHOD_POST, to_json(body)))
	var response = yield(http, "request_completed") as Array
	print(response)
	if response[1] == 200:
		token = _getToken(response)

func authenticated() -> bool:
	return token != ""
