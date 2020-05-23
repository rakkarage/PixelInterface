extends Node

const _path := "user://Store.cfg"
var _file := ConfigFile.new()
var data := {
	"all": {
		"remember": true,
	},
	"f": {
		"email": "",
		"expires": 0,
		"token": "",
		"id": ""
	},
	"n": {
		"email": "",
		"expires": 0,
		"token": ""
	}
}

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
	Utility.ok(_file.save(_path))

func _exit_tree() -> void:
	_file.close()
