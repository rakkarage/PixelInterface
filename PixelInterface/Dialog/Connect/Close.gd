extends Control

signal close_pressed

func _on_Close_pressed():
	emit_signal("close_pressed")
