extends Control

const TabButton = preload("res://Objects/TabButton.tscn")

onready var safety_check_timer: Timer = $SafetyCheckTimer

var dialogue_data: Dictionary = {
	"facts": {}, 
	"events": {12: {"name": "End", "id": 12}}, 
	"rules": {}
}

var global_data: Dictionary = {
	"facts": {}, 
	"taken_ids": {
		"F": [], 
		"GLF": [], 
		"E": [], 
		"R": [], 
		"CR": [], 
		"MO": [], 
		"OP": []
	}, 
	"dialogue_files": []
}

var current_dialogue_file: String = "NONE"

onready var editors: Dictionary = {
	"fact": $MarginContainer/VBoxContainer/HBoxContainer/FactEditor, 
	"event": $MarginContainer/VBoxContainer/HBoxContainer/EventEditor, 
	"rule": $MarginContainer/VBoxContainer/HBoxContainer/RuleEditor, 
	"none": $MarginContainer/VBoxContainer/HBoxContainer/NoneEditor
}

var currently_editing: String = "none"


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("save"):
		save_to_file(current_dialogue_file)
		$Saved.show()
		yield(get_tree().create_timer(0.8), "timeout")
		$Saved.hide()


func _ready() -> void:
	if Globals.current_project_file != "NONE":
		load_project_from_file(Globals.current_project_file)


func save_to_file(path: String) -> void:
	for i in dialogue_data.facts.values():
		if i.scope == 1:  # Globally Saved
			global_data.facts[i.id] = i
			dialogue_data.facts.erase(i.id)
	
	
	var f = File.new()
	f.open(path, File.WRITE)
	f.store_string(var2str(dialogue_data))
	f.close()
	
	f.open(Globals.current_project_file, File.WRITE)
	f.store_string(var2str(global_data))
	f.close()


func load_project_from_file(path: String) -> void:
	for i in $MarginContainer/VBoxContainer/SceneMenu/ScrollContainer/NavMenu.get_children():
		i.queue_free()
	var f = File.new()
	f.open(path, File.READ)
	var content = str2var(f.get_as_text())
	f.close()
	global_data = content
	var dir = Directory.new()
	for i in content.dialogue_files:
		if !dir.file_exists(i):
			global_data.dialogue_files.erase(i)
			continue
		var file_button = TabButton.instance()
		file_button.text = i.split("/")[-1].replace(".dialog", "")
		file_button.file_name = i
		file_button.connect("selected", self, "_on_file_selected")
		
		$MarginContainer/VBoxContainer/SceneMenu/ScrollContainer/NavMenu.add_child(file_button)
	
	IdManager.taken_ids = content.taken_ids
	
	$MarginContainer/VBoxContainer/HBoxContainer.hide()
	$MarginContainer/VBoxContainer/None.show()


func load_dialogue_file(path: String) -> void:
	var f = File.new()
	f.open(path, File.READ)
	var content = str2var(f.get_as_text())
	f.close()
	
	dialogue_data = content
	
	$MarginContainer/VBoxContainer/HBoxContainer/EntryContainer.clear()
	$MarginContainer/VBoxContainer/HBoxContainer/EntryContainer.load_entries(dialogue_data, global_data.facts)
	
	for i in editors.values():
		i.hide()
	editors.none.show()
	
	$MarginContainer/VBoxContainer/None.hide()
	$MarginContainer/VBoxContainer/HBoxContainer.show()


func _on_EntryContainer_event_selected(id) -> void:
	currently_editing = "event"
	editors.fact.hide()
	editors.rule.hide()
	editors.none.hide()
	editors.event.show()
	
	editors.event.event = dialogue_data.events[id]


func _on_EntryContainer_fact_selected(id) -> void:
	currently_editing = "fact"
	editors.event.hide()
	editors.rule.hide()
	editors.none.hide()
	editors.fact.show()
	
	editors.fact.fact = dialogue_data.facts[id] if dialogue_data.facts.has(id) else global_data.facts[id]


func _on_EntryContainer_rule_selected(id) -> void:
	currently_editing = "rule"
	editors.fact.hide()
	editors.event.hide()
	editors.none.hide()
	editors.rule.show()
	
	editors.rule.load_events(dialogue_data.events)
	editors.rule.rule = dialogue_data.rules[id]


func _on_FactEditor_fact_changed(id: int, new_value: Dictionary) -> void:
	if new_value.has("DEL"):
		dialogue_data.facts.erase(id)
		return
	dialogue_data.facts[id] = new_value


func _on_EventEditor_event_changed(id: int, event: Dictionary) -> void:
	if event.has("DEL"):
		dialogue_data.events.erase(id)
		return
	dialogue_data.events[id] = event


func _on_RuleEditor_rule_changed(id: int, new_value: Dictionary) -> void:
	if new_value.has("DEL"):
		dialogue_data.rules.erase(id)
		return
	dialogue_data.rules[id] = new_value


func _on_Button_pressed() -> void:
	print(global_data)


func _on_NewFileButton_pressed() -> void:
	$CreateNewFile.popup_centered()


func _on_CreateNewFile_dir_selected(dir: String) -> void:
	$AcceptDialog.dialog_text = dir
	$AcceptDialog.popup_centered()


func _on_AcceptDialog_confirmed() -> void:
	var f = File.new()
	f.open($AcceptDialog.dialog_text + "/" + $AcceptDialog/LineEdit.text + ".dialog", File.WRITE)
	f.store_string(var2str({"facts": {}, "events": {12: {"name": "End", "id": 12}}, "rules": {}}))
	f.close()
	global_data.dialogue_files.append($AcceptDialog.dialog_text + "/" + $AcceptDialog/LineEdit.text + ".dialog")
	
	var file_button = TabButton.instance()
	file_button.text = $AcceptDialog/LineEdit.text
	file_button.file_name = $AcceptDialog.dialog_text + "/" + $AcceptDialog/LineEdit.text + ".dialog"
	file_button.connect("selected", self, "_on_file_selected")
	
	$MarginContainer/VBoxContainer/SceneMenu/ScrollContainer/NavMenu.add_child(
		file_button
	)
	
	$AcceptDialog/LineEdit.text = ""
	file_button._on_TabButton_pressed()  # select it after creation


func _on_file_selected(file_name: String) -> void:
	if current_dialogue_file == file_name:
		$RenameDialogueFile.popup_centered()
		$RenameDialogueFile/LineEdit.placeholder_text = file_name
	save_to_file(current_dialogue_file)
	dialogue_data = {
		"facts": {}, 
		"events": {}, 
		"rules": {}
	}
	current_dialogue_file = file_name
	load_dialogue_file(file_name)


func _on_SettingsButton_pressed() -> void:
	$Settings.popup_centered()


func _on_LoadDialogueButton_pressed() -> void:
	$LoadDialogue.popup_centered()


func _on_LoadDialogue_files_selected(paths: PoolStringArray) -> void:
	for i in paths:
		if i in global_data.dialogue_files:
			continue
		var file_button = TabButton.instance()
		file_button.text = i.split("/")[-1].replace(".dialog", "")
		file_button.file_name = i
		file_button.connect("selected", self, "_on_file_selected")
		
		$MarginContainer/VBoxContainer/SceneMenu/ScrollContainer/NavMenu.add_child(file_button)
		
		global_data.dialogue_files.append(i)


func _on_SafetyCheckTimer_timeout() -> void:
	
	# put any r/poutine checks here
	
	safety_check_timer.start()


func _on_SafetyCheckButton_toggled(button_pressed: bool) -> void:
	if button_pressed:
		safety_check_timer.start()
	else:
		safety_check_timer.stop()
	$Settings/MarginContainer/VBoxContainer/CheckRPoutineButton.visible = button_pressed


func _on_RenameDialogueFile_confirmed() -> void:
	var new_name = $RenameDialogueFile/LineEdit.placeholder_text.split("/")[-1].replace
	global_data.dialogue_files.erase($RenameDialogueFile/LineEdit.placeholder_text)
	global_data.dialogue_files.append(new_name.append($RenameDialogueFile/LineEdit.text + ".dialog"))
	var dir = Directory.new()
	dir.rename($RenameDialogueFile/LineEdit.placeholder_text, new_name.append($RenameDialogueFile/LineEdit.text + ".dialog"))
	
	load_project_from_file(Globals.current_project_file)


func _on_CheckRPoutineButton_pressed() -> void:
	OS.shell_open("https://www.reddit.com/r/poutine/")
