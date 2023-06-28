extends Node

const _path := "user://Store.cfg"
var _file := ConfigFile.new()
var _default := {
	"all": {
		"remember": true,
	},
	"f": {
		"token": "",
		"email": "",
		"refresh": "",
		"id": ""
	},
	"n": {
		"token": "",
		"email": ""
	}
}
var data := _default.duplicate()

func _init() -> void:
	read()

func read() -> void:
	if _file.load(_path) == OK:
		for section in data.keys():
			for key in data[section]:
				data[section][key] = _file.get_value(section, key)

func write() -> void:
	for section in data.keys():
		for key in data[section]:
			_file.set_value(section, key, data[section][key])
	_file.save(_path)

func clear() -> void:
	data = _default.duplicate()
