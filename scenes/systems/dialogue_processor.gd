extends Node

# generic file loaded once here - just so NPCs arnt all holding individual copies
var npc_generic_dialogue:Dictionary = _load_file("res://assets/dialogue/npc_rand_dialogue.json")

static func _load_file(file_path) -> Dictionary:
	var dialogue_file = FileAccess.open(file_path, FileAccess.READ)
	if dialogue_file == null:
		print("COULD NOT OPEN FILE")
	return JSON.parse_string(dialogue_file.get_as_text())
	

static func _filter_dialogue_list(dialogue_list:Array, attribute:String, filter) -> Array:
	var filtered_dialogue_list = []
	for dialogue in dialogue_list:
		if dialogue[attribute] == filter:
			filtered_dialogue_list.append(dialogue)
			
	return filtered_dialogue_list

func _get_random_npc_dialogue(npc_status: Enums.NpcState) -> Dictionary:
	var possible_dialogue:Array = _return_npc_dialogue_off_type(Enums.NpcState.keys()[npc_status])
	# run filtering
	possible_dialogue = _filter_dialogue_list(possible_dialogue, "is_start", true)
	# return result
	return possible_dialogue[randi_range(0, possible_dialogue.size() - 1)]

func _return_npc_dialogue_off_type(npc_status:String):
	if npc_status != "" && npc_generic_dialogue.has(npc_status):
		return npc_generic_dialogue[npc_status]
	print("Type/Status passed in could not be found.")
	return

func _get_next_dialogue(next_id: String):
	var status = "responses"
	var possible_dialogue:Array = _return_npc_dialogue_off_type(status)
	
	for dialogue in possible_dialogue:
		if dialogue["id"] == next_id:
			return dialogue
	
	print("Could not find next_id of " + next_id + " in dialogue array.")	
	return
