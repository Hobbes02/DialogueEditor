extends HBoxContainer

onready var equal_type = $EqualType
onready var fact = $Fact

var criterium: Dictionary = {
	"fact": 0, 
	"fact_scope": 0, 
	"equal_type": "==", 
	"value": 0, 
	"id": 0
} setget set_criterium

signal criterium_changed(id, new_value)


func _ready() -> void:
	equal_type.clear()
	fact.clear()
	for i in range(len(["==", ">", "<", "!=", ">=", "<="])):
		equal_type.add_item(["==", ">", "<", "!=", ">=", "<="][i])
		equal_type.set_item_metadata(i, ["==", ">", "<", "!=", ">=", "<="][i])
	fact.add_item("Select A Fact", 0)
	fact.selected = fact.get_item_index(0)


func create(facts: Dictionary) -> void:
	for i in facts.values():
		fact.add_item(i.name, i.id)
		fact.set_item_metadata(fact.get_item_index(i.id), i.scope)


func set_criterium(new_value: Dictionary) -> void:
	criterium = new_value
	fact.selected = fact.get_item_index(criterium.fact)
	equal_type.selected = ["==", ">", "<", "!=", ">=", "<="].find(criterium.equal_type)
	$SpinBox.value = criterium.value


func _on_Fact_item_selected(index: int) -> void:
	criterium.fact = fact.get_item_id(index)
	criterium.fact_scope = fact.get_item_metadata(index)
	emit_signal("criterium_changed", criterium.id, criterium)


func _on_EqualType_item_selected(index: int) -> void:
	criterium.equal_type = equal_type.get_item_metadata(index)
	emit_signal("criterium_changed", criterium.id, criterium) 


func _on_SpinBox_value_changed(value: float) -> void:
	criterium.value = value
	emit_signal("criterium_changed", criterium.id, criterium)


func _on_DeleteButton_pressed() -> void:
	emit_signal("criterium_changed", criterium.id, {"DEL": true})
