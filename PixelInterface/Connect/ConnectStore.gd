extends Store

func _init() -> void:
	_default = {
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
	super._init()
