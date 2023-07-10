extends PanelContainer

const Entry = preload("res://Objects/Entry.tscn")

var nodes: Dictionary = {
	"fact": {}, 
	"gfact": {}, 
	"event": {}, 
	"rule": {}
}

onready var containers: Dictionary = {
	"fact": $VBoxContainer/MarginContainer/ScrollContainer/VBoxContainer/FactContainer, 
	"event": $VBoxContainer/MarginContainer/ScrollContainer/VBoxContainer/EventContainer, 
	"rule": $VBoxContainer/MarginContainer/ScrollContainer/VBoxContainer/RuleContainer
}

onready var editor = $"../../../.."

signal fact_selected(id)
signal event_selected(id)
signal rule_selected(id)


func _on_fact_selected(id: int) -> void:
	emit_signal("fact_selected", id)


func _on_event_selected(id: int) -> void:
	emit_signal("event_selected", id)


func _on_rule_selected(id: int) -> void:
	emit_signal("rule_selected", id)


func _on_NewFactButton_pressed() -> void:
	var fact = Entry.instance()
	fact.type = fact.TYPES.Fact
	fact.id = IdManager.new_id("F")
	fact.text = "F" + str(fact.id)
	fact.name = "F" + str(fact.id)
	containers.fact.add_child(fact)
	fact.connect("selected", self, "_on_fact_selected")
	nodes.fact[fact.id] = fact
	editor.dialogue_data.facts[fact.id] = {"name": "F" + str(fact.id), "value": 0, "scope": 0, "id": fact.id}
	emit_signal("fact_selected", fact.id)


func _on_NewEventButton_pressed() -> void:
	var event = Entry.instance()
	event.type = event.TYPES.Event
	event.id = IdManager.new_id("E")
	event.text = "E" + str(event.id)
	event.name = "E" + str(event.id)
	containers.event.add_child(event)
	event.connect("selected", self, "_on_event_selected")
	nodes.event[event.id] = event
	editor.dialogue_data.events[event.id] = {"name": "E" + str(event.id), "id": event.id}
	emit_signal("event_selected", event.id)


func _on_NewRuleButton_pressed() -> void:
	var rule = Entry.instance()
	rule.type = rule.TYPES.Rule
	rule.id = IdManager.new_id("R")
	rule.text = "R" + str(rule.id)
	rule.name = "R" + str(rule.id)
	containers.rule.add_child(rule)
	rule.connect("selected", self, "_on_rule_selected")
	nodes.rule[rule.id] = rule
	editor.dialogue_data.rules[rule.id] = {
		"name": "R" + str(rule.id), 
		"dialogue": "", 
		"speaker": "", 
		"options": {}, 
		"triggered_by": 0, 
		"triggers": 0, 
		"once": false, 
		"importance": 0, 
		"criteria": {}, 
		"modifications": {}, 
		"id": rule.id
	}
	emit_signal("rule_selected", rule.id)


func clear() -> void:
	for i in containers.fact.get_children():
		i.queue_free()
	for i in containers.event.get_children():
		i.queue_free()
	for i in containers.rule.get_children():
		i.queue_free()
	nodes.gfact.clear()
	nodes.fact.clear()
	nodes.event.clear()
	nodes.rule.clear()


func load_entries(entries: Dictionary, global_facts: Dictionary) -> void:
	for f in global_facts.values():
		var fact = Entry.instance()
		fact.type = fact.TYPES.GFact
		fact.id = f.id
		fact.text = f.name
		fact.name = "G" + str(f.id)
		containers.fact.add_child(fact)
		fact.connect("selected", self, "_on_fact_selected")
		nodes.gfact[fact.id] = fact
	for f in entries.facts.values():
		var fact = Entry.instance()
		fact.type = fact.TYPES.Fact
		fact.id = f.id
		fact.text = f.name
		fact.name = "F" + str(f.id)
		containers.fact.add_child(fact)
		fact.connect("selected", self, "_on_fact_selected")
		nodes.fact[fact.id] = fact
	for e in entries.events.values():
		var event = Entry.instance()
		event.type = event.TYPES.Event
		event.id = e.id
		event.text = e.name
		event.name = "E" + str(e.id)
		containers.event.add_child(event)
		event.connect("selected", self, "_on_event_selected")
		nodes.event[event.id] = event
	for r in entries.rules.values():
		var rule = Entry.instance()
		rule.type = rule.TYPES.Rule
		rule.id = r.id
		rule.text = r.name
		rule.name = "R" + str(r.id)
		containers.rule.add_child(rule)
		rule.connect("selected", self, "_on_rule_selected")
		nodes.rule[rule.id] = rule


func _on_FactEditor_fact_changed(id: int, new_value: Dictionary) -> void:
	if new_value.has("DEL"):
		if new_value.scope == 1:
			nodes.gfact[id].queue_free()
			nodes.gfact.erase(id)
		else:
			nodes.fact[id].queue_free()
			nodes.fact.erase(id)
	elif new_value.id != id:
		if new_value.scope == 1:
			nodes.fact[id].id = new_value.id
			yield(get_tree(), "idle_frame")
			nodes.gfact[new_value.id] = nodes.fact[id]
			nodes.fact.erase(id)
			editor.dialogue_data.facts.erase(id)
		else:
			nodes.gfact[id].id = new_value.id
			yield(get_tree(), "idle_frame")
			nodes.fact[new_value.id] = nodes.gfact[id]
			nodes.gfact.erase(id)
			editor.global_data.facts.erase(id)
	else:
		if new_value.scope == 1:
			nodes.gfact[id].text = new_value.name
		else:
			nodes.fact[id].text = new_value.name


func _on_EventEditor_event_changed(id: int, event: Dictionary) -> void:
	if event.has("DEL"):
		nodes.event[id].queue_free()
		nodes.event.erase(id)
	else:
		nodes.event[id].text = event.name


func _on_RuleEditor_rule_changed(id: int, new_value: Dictionary) -> void:
	if new_value.has("DEL"):
		nodes.rule[id].queue_free()
		nodes.rule.erase(id)
	else:
		nodes.rule[id].text = new_value.name
