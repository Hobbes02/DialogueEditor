extends Panel

var event: Dictionary = {
	"name": "", 
	"id": 0
} setget set_event

signal event_changed(id, event)

onready var editor = $"../../../.."


func set_event(new_value: Dictionary) -> void:
	event = new_value
	$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/NameEdit/LineEdit.text = event.name
	$MarginContainer/VBoxContainer/Label.text = "ID: " + str(event.id)



func _on_DeleteButton_pressed() -> void:
	emit_signal("event_changed", event.id, {"DEL": true})
	hide()
	$"../NoneEditor".show()


func _on_LineEdit_text_entered(new_text: String) -> void:
	for i in editor.dialogue_data.events.values():
		if i.name == new_text:
			editor.get_node("ErrorSameName").show()
			yield(get_tree().create_timer(0.8), "timeout")
			editor.get_node("ErrorSameName").hide()
			$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/NameEdit/LineEdit.text = event.name
			return
	event.name = new_text
	emit_signal("event_changed", event.id, event)
