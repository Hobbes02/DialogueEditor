extends HBoxContainer

onready var equal_type = $EqualType
onready var fact = $Fact

var modification: Dictionary = {
	"fact": 0, 
	"fact_scope": 0, 
	"equal_type": "+=", 
	"value": 0, 
	"id": 0
} setget set_modification

signal modification_changed(id, new_value)


func _ready() -> void:
	equal_type.clear()
	fact.clear()
	for i in range(len(["+=", "="])):
		equal_type.add_item(["+=", "="][i])
		equal_type.set_item_metadata(i, ["+=", "="][i])
	equal_type.selected = 0
	fact.add_item("Select A Fact", 0)
	fact.selected = fact.get_item_index(0)


func create(facts: Dictionary) -> void:
	for i in facts.values():
		fact.add_item(i.name, i.id)
		fact.set_item_metadata(fact.get_item_index(i.id), i.scope)


func set_modification(new_value: Dictionary) -> void:
	modification = new_value
	fact.selected = fact.get_item_index(modification.fact)
	match modification.equal_type:
		"=":
			equal_type.selected = 1
		"+=":
			equal_type.selected = 0
	$SpinBox.value = modification.value


func _on_Fact_item_selected(index: int) -> void:
	modification.fact = fact.get_item_id(index)
	modification.fact_scope = fact.get_item_metadata(index)
	emit_signal("modification_changed", modification.id, modification)


func _on_EqualType_item_selected(index: int) -> void:
	modification.equal_type = equal_type.get_item_metadata(index)
	emit_signal("modification_changed", modification.id, modification) 


func _on_SpinBox_value_changed(value: float) -> void:
	modification.value = value
	emit_signal("modification_changed", modification.id, modification)


func _on_DeleteButton_pressed() -> void:
	emit_signal("modification_changed", modification.id, {"DEL": true})
