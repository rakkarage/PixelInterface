extends Connect

var _client : NakamaClient

func _ready():
	_client = Nakama.create_client("defaultkey", "127.0.0.1", 7350, "http")
