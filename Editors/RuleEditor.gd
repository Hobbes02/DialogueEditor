extends Panel

const Criterium = preload("res://Objects/Criterium.tscn")
const Modification = preload("res://Objects/Modification.tscn")
const Option = preload("res://Objects/Option.tscn")

onready var nodes: Dictionary = {
	"criteria": $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CriteriaModifications/Criteria/Criteria/ScrollContainer/CriteriaContainer, 
	"modifications": $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CriteriaModifications/Modifications/Modifications/ScrollContainer/ModificationsContainer, 
	"options": $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CriteriaModifications/Options/Options/ScrollContainer/OptionsContainer, 
	"triggered_by": $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/TriggeredByEdit/OptionButton, 
	"triggers": $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/TriggersEdit/OptionButton
}

var rule: Dictionary = {
	"name": "", 
	"dialogue": "", 
	"speaker": "", 
	"options": {}, 
	"triggered_by": 0, 
	"triggers": 0, 
	"once": false, 
	"importance": 0, 
	"criteria": {}, 
	"modifications": {}, 
	"id": 0
} setget set_rule

signal rule_changed(id, new_value)

onready var editor = $"../../../.."


func set_rule(new_value: Dictionary) -> void:
	rule = new_value
	
	$MarginContainer/VBoxContainer/Label.text = "ID: " + str(rule.id)
	$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/NameEdit/LineEdit.text = rule.name
	$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/DialogueEdit/TextEdit.text = rule.dialogue
	$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/SpeakerEdit/LineEdit.text = rule.speaker
	nodes.triggered_by.selected = nodes.triggered_by.get_item_index(rule.triggered_by)
	
	nodes.triggers.selected = nodes.triggers.get_item_index(rule.triggers)
	
	$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/OnceEdit/CheckBox.pressed = rule.once
	
	$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/ImportanceEdit/OptionButton.value = rule.importance
	
	for i in nodes.criteria.get_children():
		i.queue_free()
	
	for i in nodes.modifications.get_children():
		i.queue_free()
	
	for i in nodes.options.get_children():
		i.queue_free()
	
	for i in rule.criteria.values():
		add_criterium(i.fact, i.fact_scope, i.equal_type, i.value, i.id)
	
	for i in rule.modifications.values():
		add_modification(i.fact, i.fact_scope, i.equal_type, i.value, i.id)
	
	for i in rule.options.values():
		add_option(i.name, i.triggers, i.id)


func load_events(events: Dictionary) -> void:
	nodes.triggered_by.clear()
	nodes.triggers.clear()
	for i in events.values():
		nodes.triggered_by.add_item(i.name, i.id)
		nodes.triggers.add_item(i.name, i.id)


func add_criterium(fact: int, fact_scope: int, equal_type: String, value: int, id: int = -1) -> void:
	var criterium = Criterium.instance()
	
	nodes.criteria.add_child(criterium)
	
	criterium.create($"../../../..".dialogue_data.facts)
	criterium.create($"../../../..".global_data.facts)
	
	criterium.criterium = {
		"fact": fact, 
		"fact_scope": fact_scope, 
		"equal_type": equal_type, 
		"value": value, 
		"id": (IdManager.new_id("CR") if id == -1 else id)
	}
	
	criterium.connect("criterium_changed", self, "_on_criterium_changed")
	rule.criteria[criterium.criterium.id] = criterium.criterium


func _on_criterium_changed(id: int, new_value: Dictionary) -> void:
	if new_value.has("DEL"):
		rule.criteria.erase(id)
		for i in nodes.criteria.get_children():
			if i.criterium.id == id:
				i.queue_free()
	else:
		rule.criteria[id] = new_value
	emit_signal("rule_changed", rule.id, rule)


func add_modification(fact: int, fact_scope: int, equal_type: String, value: int, id: int = -1) -> void:
	var modification = Modification.instance()
	
	nodes.modifications.add_child(modification)
	
	modification.create($"../../../..".dialogue_data.facts)
	modification.create($"../../../..".global_data.facts)
	
	modification.modification = {
		"fact": fact, 
		"fact_scope": fact_scope, 
		"equal_type": equal_type, 
		"value": value, 
		"id": (IdManager.new_id("MO") if id == -1 else id)
	}
	
	modification.connect("modification_changed", self, "_on_modification_changed")
	rule.modifications[modification.modification.id] = modification.modification


func _on_modification_changed(id: int, new_value: Dictionary) -> void:
	if new_value.has("DEL"):
		rule.modifications.erase(id)
		for i in nodes.modifications.get_children():
			if i.modification.id == id:
				i.queue_free()
	else:
		rule.modifications[id] = new_value
	emit_signal("rule_changed", rule.id, rule)


func add_option(option_name: String, triggers: int = 0, id: int = -1) -> void:
	var option = Option.instance()
	nodes.options.add_child(option)
	
	option.option = {
		"name": option_name, 
		"triggers": triggers, 
		"id": id if id != -1 else IdManager.new_id("OP")
	}
	option.load_events(editor.dialogue_data.events)
	option.connect("option_changed", self, "_on_option_changed")


func _on_option_changed(id: int, new_value: Dictionary) -> void:
	if new_value.has("DEL"):
		rule.options.erase(id)
		for i in nodes.options.get_children():
			if i.option.id == id:
				i.queue_free()
	else:
		rule.options[id] = new_value
	emit_signal("rule_changed", rule.id, rule)


func _on_TextEdit_text_changed() -> void:
	rule.dialogue = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/DialogueEdit/TextEdit.text
	emit_signal("rule_changed", rule.id, rule)


func _on_Speaker_text_changed(new_text: String) -> void:
	rule.speaker = new_text
	emit_signal("rule_changed", rule.id, rule)


func _on_TriggeredBy_item_selected(index: int) -> void:
	rule.triggered_by = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/TriggeredByEdit/OptionButton.get_item_id(index)
	emit_signal("rule_changed", rule.id, rule)


func _on_Triggers_item_selected(index: int) -> void:
	rule.triggers = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/TriggersEdit/OptionButton.get_item_id(index)
	emit_signal("rule_changed", rule.id, rule)


func _on_Once_toggled(button_pressed: bool) -> void:
	rule.once = button_pressed
	emit_signal("rule_changed", rule.id, rule)


func _on_Importance_value_changed(value: float) -> void:
	rule.importance = value
	emit_signal("rule_changed", rule.id, rule)


func _on_NewCriteriaButton_pressed() -> void:
	add_criterium(0, 0, "==", 0)
	
	emit_signal("rule_changed", rule.id, rule)


func _on_NewModButton_pressed() -> void:
	add_modification(0, 0, "=", 0)
	
	emit_signal("rule_changed", rule.id, rule)


func _on_DeleteButton_pressed() -> void:
	emit_signal("rule_changed", rule.id, {"DEL": true})
	hide()
	$"../NoneEditor".show()


func _on_LineEdit_text_entered(new_text: String) -> void:
	for i in editor.dialogue_data.facts.values():
		if i.name == new_text:
			editor.get_node("ErrorSameName").show()
			yield(get_tree().create_timer(0.8), "timeout")
			editor.get_node("ErrorSameName").hide()
			$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/NameEdit/LineEdit.text = rule.name
			return
	rule.name = new_text
	emit_signal("rule_changed", rule.id, rule)



func _on_NewOptionButton_pressed() -> void:
	add_option("")
