extends Node

const _storeFile := "res://Store.cfg"
# const _storeFile := "user://Store.cfg"
var _store := ConfigFile.new()
var data := {
	"connect": {
		"remember": true,
		"email": ""
	},
	"firebase": {
		"token": ""
	},
	"nakama": {
		"token": ""
	}
}

func _init() -> void:
	_load()

func _load() -> void:
	Utility.ok(_store.load(_storeFile))
	for section in data.keys():
		for key in data[section]:
			var default = data[section][key]
			data[section][key] = _store.get_value(section, key, default)

func _save() -> void:
	for section in data.keys():
		for key in data[section]:
			_store.set_value(section, key, data[section][key])
	Utility.ok(_store.save(_storeFile))
