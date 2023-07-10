extends Panel


var fact: Dictionary = {
	"name": "", 
	"value": 0, 
	"scope": 0, 
	"id": 0
} setget set_fact

signal fact_changed(id, new_value)

onready var editor = $"../../../.."


func set_fact(new_value: Dictionary) -> void:
	fact = new_value
	$MarginContainer/VBoxContainer/Label.text = "ID: " + str(fact.id)
	$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/NameEdit/LineEdit.text = fact.name
	$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/ValueEdit/SpinBox.value = fact.value
	$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/ScopeEdit/LineEdit.selected = fact.scope


func _on_LineEdit_text_entered(new_text: String) -> void:
	for i in editor.dialogue_data.facts.values():
		if i.name == new_text:
			editor.get_node("ErrorSameName").show()
			yield(get_tree().create_timer(0.8), "timeout")
			editor.get_node("ErrorSameName").hide()
			$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/NameEdit/LineEdit.text = fact.name
			return
	fact.name = new_text
	emit_signal("fact_changed", fact.id, fact)


func _on_SpinBox_value_changed(value: float) -> void:
	fact.value = value
	emit_signal("fact_changed", fact.id, fact)


func _on_LineEdit_item_selected(index: int) -> void:  # scope changed
	fact.scope = index
	var new_id = IdManager.new_id("GLF")
	if fact.scope == 1:  # global
		editor.global_data.facts[new_id] = {"name": fact.name, "value": fact.value, "scope": fact.scope, "id": new_id}
	elif fact.scope == 0:  # local
		editor.dialogue_data.facts[new_id] = {"name": fact.name, "value": fact.value, "scope": fact.scope, "id": new_id}
	emit_signal("fact_changed", fact.id, {
		"name": fact.name, 
		"value": fact.value, 
		"scope": fact.scope, 
		"id": new_id
	})
	fact.id = new_id


func _on_DeleteButton_pressed() -> void:
	emit_signal("fact_changed", fact.id, {"DEL": true, "scope": fact.scope})
	hide()
	$"../NoneEditor".show()
