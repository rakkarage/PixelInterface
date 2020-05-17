extends Object
class_name Store

const _storeFile := "user://Store.cfg"
var _store := ConfigFile.new()
var _section := ""
var _key := ""
var _value : String setget setValue, getValue

func _init(section: String, key: String) -> void:
	Utility.ok(_store.load(_storeFile))
	_section = section
	_key = key

func setValue(value: String) -> void:
	setConfig(_section, _key, value)

func setConfig(section: String, key: String, value: String) -> void:
	_store.set_value(section, key, value)
	Utility.ok(_store.save(_storeFile))

func getValue() -> String:
	return getConfig(_section, _key)

func getConfig(section: String, key: String, default: String = "") -> String:
	return _store.get_value(section, key, default)

func clearValue() -> void:
	clearConfig(_section, _key)

func clearConfig(section: String, key: String) -> void:
	_store.erase_section_key(section, key)
