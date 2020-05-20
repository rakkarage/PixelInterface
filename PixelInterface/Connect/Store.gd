extends Object
class_name Store

const _storeFile := "user://Store.cfg"
var _store := ConfigFile.new()
var _section := ""
var _key := ""

var data : String setget _setValue, _getValue

func _init(section: String, key: String) -> void:
	Utility.ok(_store.load(_storeFile))
	_section = section
	_key = key

func _setValue(value: String) -> void:
	setConfig(_section, _key, value)

func setConfig(section: String, key: String, value: String) -> void:
	_store.set_value(section, key, value)
	Utility.ok(_store.save(_storeFile))

func _getValue() -> String:
	return getConfig(_section, _key)

func getConfig(section: String, key: String, default: String = "") -> String:
	return _store.get_value(section, key, default)

func clear() -> void:
	clearConfig(_section, _key)

func clearConfig(section: String, key: String) -> void:
	_store.erase_section_key(section, key)
	Utility.ok(_store.save(_storeFile))
