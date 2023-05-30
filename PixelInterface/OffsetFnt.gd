@tool
extends EditorScript

const _font := "res://Interface/Font/Venice.fnt"
const _offset := -1

func _run() -> void:
	var lines := _getFileText(_font).split("\n")
	for i in range(lines.size()):
		if lines[i].begins_with("char id="):
			var start := lines[i].find("yoffset=") + len("yoffset=")
			var end := lines[i].find(" ", start)
			var yoffset_str := lines[i].substr(start, end - start)
			var yoffset := str(int(yoffset_str) + _offset)
			lines[i] = lines[i].substr(0, start) + yoffset + lines[i].substr(end, lines[i].length() - end)
	var last := lines.size() - 1
	if lines[last].is_empty():
		lines.remove_at(last)
	_setFileText(_font, "\n".join(lines))

func _getFileText(path: String) -> String:
	return FileAccess.open(path, FileAccess.READ).get_as_text()

func _setFileText(path: String, text: String) -> void:
	FileAccess.open(path, FileAccess.READ_WRITE).store_string(text)
