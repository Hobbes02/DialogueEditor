extends ToolButton

var file_name: String = ""


signal selected(file_name)


func _on_TabButton_pressed() -> void:
	emit_signal("selected", file_name)
