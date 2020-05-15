extends Node

const _storeFile := "user://Store.cfg"
var _store := ConfigFile.new()

func _ready() -> void:
	Utility.ok(_store.load(_storeFile))

func setValue(section: String, key: String, value: String) -> void:
	_store.set_value(section, key, value)
	Utility.ok(_store.save(_storeFile))

func getValue(section: String, key: String, default: String = "") -> String:
	return _store.get_value(section, key, default)

func clearValue(section: String, key: String) -> void:
	_store.erase_section_key(section, key)
