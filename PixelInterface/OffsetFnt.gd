## Used to offset the yoffset of a font file.
## This is useful for fonts that 'centered' incorrectly.
@tool
extends EditorScript

const _font := "res://Interface/Font/Venice.fnt"
const _offset := -1

func _get_file_text(path: String) -> String:
	return FileAccess.open(path, FileAccess.READ).get_as_text()

func _set_file_text(path: String, text: String) -> void:
	FileAccess.open(path, FileAccess.READ_WRITE).store_string(text)

func _run() -> void:
	var lines := _get_file_text(_font).split("\n")
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
	_set_file_text(_font, "\n".join(lines))
