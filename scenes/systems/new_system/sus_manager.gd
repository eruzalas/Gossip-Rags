extends Node
#Part of the new system - Lorenzo

var sus_amount: float
var target: Node
var target_sus_comp: Node
var player_sus: float
var costume_sus: float
var costume_sus_modifier: float 

#experimenting with state values
@export var wary_thresh: float
@export var alert_thresh: float
@export var max_thresh: float
var state: String

signal change_total_sus(target, sus_amount)

func _on_sus_event(player, detected_npcs, detected_duration) -> void:
	
	costume_sus_modifier = 1.00
	player_sus = _retrieve_target_sus(player)
	
	if(player.new_costume != null):
		costume_sus = _retrieve_target_sus(player.new_costume)
		#costume_sus_modifier = Retrieve costume sus modifier (in future)
	
	player_sus += costume_sus_modifier*_calculate_added_sus( detected_npcs, detected_duration)	
	
	change_total_sus.emit(player, player_sus)
	
	if(player.new_costume != null):
		change_total_sus.emit(player.new_costume, costume_sus)
	

func _retrieve_target_sus(target) -> float:
	
	target_sus_comp = target.get_node("SusComponent")
	return target_sus_comp.suspicion
	

func _calculate_added_sus(detected_npcs, detected_duration) -> float:
	var calculated_added_suspicion: float
	
	calculated_added_suspicion = (detected_npcs + 1)^detected_duration
	
	return calculated_added_suspicion






#func _change_state(target) -> String:
	#
	#target_sus = _retrieve_target_sus(target)
	#if(target_sus < wary_thresh):
		#state = "calm"
		##print("state: " + state)
		#
	#elif(target_sus >= wary_thresh && target_sus < alert_thresh):
		#state = "wary"
		##print("state: " + state)
		#
	#elif(target_sus >= alert_thresh && target_sus < max_thresh):
		#state = "alert"
		##print("state: " + state)
		#
	#elif(target_sus >= max_thresh):
		#state = "maxed"
		##print("state: " + state)
		#
	#return state
	
