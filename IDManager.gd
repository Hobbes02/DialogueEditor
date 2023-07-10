extends Node

onready var rng = RandomNumberGenerator.new()


var taken_ids = {
	"F": [], 
	"GLF": [], 
	"R": [], 
	"E": [], 
	"CR": [], 
	"MO": [], 
	"OP": []
}


func _ready() -> void:
	rng.randomize()
	rng.seed = rng.randi_range(100, 999999999)


func new_id(type: String) -> int:
	var id: int = rng.randi_range(10000000, 99999999)
	while id in taken_ids[type]:
		id = rng.randi_range(10000000, 99999999)
		rng.randomize()
	taken_ids[type].append(id)
	rng.seed = id
	return id

func new_id_unrandom(type: String) -> int:
	var highest: int = 0
	for i in taken_ids[type]:
		if i > highest:
			highest = i
	taken_ids[type].append(highest + 1)
	return highest + 1
