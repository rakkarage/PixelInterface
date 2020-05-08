extends Control

onready var _title := $Title
onready var _text := $Text
onready var _save := $HBox/Save
onready var _delete := $HBox/Delete

var new = false
var state := {
	"title": {},
	"text": {}
} setget setState

func setState(value: Dictionary):
	state = value
	_title = state.title.stringValue
	_text = state.text.stringValue

func _ready() -> void:
	Utility.ok(_save.connect("pressed", self, "saveDoc"))
	Utility.ok(_delete.connect("pressed", self, "deleteDoc"))
	Utility.ok(Firebase.connect("docChanged", self, "_onDocChanged"))

func loadDoc(http: HTTPRequest) -> void:
	Firebase.loadDoc("users/" + Firebase.state.id, http)
	_disableInput()

func saveDoc(http: HTTPRequest) -> void:
	state.title = { "stringValue": _title.text}
	state.text = { "stringValue": _text.text}
	if new:
		Firebase.saveDoc("users?docuementId=" + Firebase.state.id, state, http)
	else:
		Firebase.updateDoc("users/" + Firebase.state.id, state, http)
	_disableInput()

func deleteDoc(http: HTTPRequest) -> void:
	Firebase.deleteDoc("users/" + Firebase.state.id, http)
	_disableInput()

func _onDocChanged(response: Array) -> void:
	if response[1] == 200:
		var o := JSON.parse(response[3].get_string_from_ascii()).result as Dictionary
		state = o.fields;
	_enableInput()

func _disableInput() -> void:
	_save.disabled = true
	_delete.disabled = true

func _enableInput() -> void:
	_save.disabled = false
	_delete.disabled = false

###move all this code to connect to use http and sounds etc!!!!!!!!!!!!!!
