extends ToolButton


enum TYPES {
	Fact, 
	GFact, 
	Event, 
	Rule
}

var id: int = 0
var type

signal selected(id)


func _on_Entry_pressed() -> void:
	emit_signal("selected", id)
