extends Control

onready var _title := $Panel/VBox/Title
onready var _text := $Panel/VBox/Text
onready var _save := $HBox/Save
onready var _delete := $HBox/Delete

var new = false
var _state := {
	"title": { "stringValue": "" },
	"text": { "stringValue": "" }
}

func _setState(value: Dictionary):
	_state = value.duplicate()
	_title = _state.title.stringValue
	_text = _state.text.stringValue

func _ready() -> void:
	Utility.ok(_save.connect("pressed", self, "saveDoc"))
	Utility.ok(_delete.connect("pressed", self, "deleteDoc"))
	Utility.ok(Firebase.connect("docChanged", self, "_onDocChanged"))

func loadDoc(http: HTTPRequest) -> void:
	Firebase.loadDoc("users/%s", http)
	_disableInput()

func saveDoc(http: HTTPRequest) -> void:
	_state.title.stringValue = _title.text
	_state.text.stringValue = _text.text
	if new:
		Firebase.saveDoc("users?docuementId=%s", _state, http)
	else:
		Firebase.updateDoc("users/%s", _state, http)
	_disableInput()

func deleteDoc(http: HTTPRequest) -> void:
	Firebase.deleteDoc("users/%s", http)
	_disableInput()

func _onDocChanged(response: Array) -> void:
	if response[1] == 200:
		var o := JSON.parse(response[3].get_string_from_ascii()).result as Dictionary
		_setState(o.fields);
	_enableInput()

func _disableInput() -> void:
	_save.disabled = true
	_delete.disabled = true

func _enableInput() -> void:
	_save.disabled = false
	_delete.disabled = false
