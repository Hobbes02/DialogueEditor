extends HBoxContainer

onready var name_edit = $NameEdit
onready var triggers = $TriggersSelect

var option: Dictionary = {
	"name": "", 
	"triggers": 0, 
	"id": 0
} setget set_option

signal option_changed(id, new_value)


func set_option(new_value: Dictionary) -> void:
	option = new_value
	$NameEdit.text = option.name
	triggers.selected = triggers.get_item_index(option.triggers) if option.triggers != 0 else 0


func load_events(events: Dictionary) -> void:
	triggers.clear()
	for i in events.values():
		triggers.add_item(i.name, i.id)
	triggers.selected = 0


func _on_NameEdit_text_entered(new_text: String) -> void:
	option.name = new_text
	emit_signal("option_changed", option.id, option)


func _on_TriggersSelect_item_selected(index: int) -> void:
	option.triggers = triggers.get_item_id(index)
	emit_signal("option_changed", option.id, option)


func _on_DeleteButton_pressed() -> void:
	emit_signal("option_changed", option.id, {"DEL": true})
