extends Control

var new_proj_name: String = ""


func _on_NewProjectButton_pressed() -> void:
	$NameProject.popup()


func _on_LoadButton_pressed() -> void:
	$LocateProject.popup_centered()


func _on_NameProject_confirmed() -> void:
	new_proj_name = $NameProject/LineEdit.text
	$SelectProjectFolder.popup_centered()


func _on_SelectProjectFolder_dir_selected(dir: String) -> void:
	var f = File.new()
	f.open(dir + "/" + new_proj_name + ".ds", File.WRITE)
	f.store_string(var2str({
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
	}))
	f.close()
	
	Globals.current_project_file = dir + "/" + new_proj_name + ".ds"
	
	get_tree().change_scene("res://Editors/Editor.tscn")
	


func _on_LocateProject_file_selected(path: String) -> void:
	Globals.current_project_file = path
	
	get_tree().change_scene("res://Editors/Editor.tscn")
