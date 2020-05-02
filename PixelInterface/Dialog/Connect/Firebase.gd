extends Node

const lookup := "https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=%s"
const signInUrl := "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=%s"
const signUpUrl := "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=%s"
var apiKey := ""
var token := ""

signal signedIn(r)
signal signedUp(r)

func _ready() -> void:
	var f = File.new()
	f.open("res://PixelInterface/Dialog/Connect/apikey.txt", File.READ)
	apiKey = f.get_as_text()
	f.close()

func _getToken(response: Array) -> String:
	var json = JSON.parse(response[3].get_string_from_ascii()).result as Dictionary
	return json.idToken

# func _api(http: HTTPRequest, url: String, body: Dictionary) -> bool:
# 	print("api: " + JSON.print(body))
# 	Utility.ok(http.request(url % apiKey, [], false, HTTPClient.METHOD_POST, to_json(body)))
# 	var response = yield(http, "request_completed") as Array
# 	print(response)
# 	if response[1] == 200:
# 		token = _getToken(response)
# 		print(token)
# 		return true
# 	else:
# 		return false

func signIn(http: HTTPRequest, email : String, password : String) -> void:
	var body := { "email" : email, "password" : password }
	Utility.ok(http.request(signInUrl % apiKey, [], false, HTTPClient.METHOD_POST, to_json(body)))
	var response = yield(http, "request_completed")
	if response[1] == 200:
		token = _getToken(response)
	emit_signal("signedIn", response)
	
	# print(result)
	# Utility.ok(result.error)
	# print(result.result)
	# var response = JSON.parse(result.result)
	# print(response)

	# if response.code == 200:
	# 	token = response.result.idToken

func signUp(http: HTTPRequest, email : String, password : String) -> void:
	var body := { "email" : email, "password" : password }
	Utility.ok(http.request(signUpUrl % apiKey, [], false, HTTPClient.METHOD_POST, to_json(body)))
	var result = JSON.parse((yield(http, "request_completed") as Array)[3].get_string_from_ascii())
	Utility.ok(result.error)
	var response = result.result
	if response.code == 200:
		token = response.result.idToken
	emit_signal("signedUp", response)

func authenticated() -> bool:
	return not token.empty()
	# if not token.empty():
	# 	if _api(http, lookup, { "idToken" : token }):
	# 		if not token.empty():
	# 			return true
	# return false;
