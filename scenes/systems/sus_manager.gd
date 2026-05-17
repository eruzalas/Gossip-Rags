extends Node
#Part of the new system - Lorenzo

var sus_amount: float
var target: Node
var target_sus_comp: Node
var target_sus: float

#experimenting with state values
@export var wary_thresh: float
@export var alert_thresh: float
@export var max_thresh: float
var state: String

signal change_total_sus(target, sus_amount)

func _on_sus_event(target, detected_npcs) -> void:
	
	target_sus = _retrieve_target_sus(target)
	#Calculations
	
	
	
	
	
	change_total_sus.emit(target, sus_amount)
	


func _retrieve_target_sus(target) -> float:
	
	target_sus_comp = target.get_node("SusComponent")
	return target_sus_comp.suspicion
	

func _change_state(target) -> String:
	
	target_sus = _retrieve_target_sus(target)
	if(target_sus < wary_thresh):
		state = "calm"
		#print("state: " + state)
		
	elif(target_sus >= wary_thresh && target_sus < alert_thresh):
		state = "wary"
		#print("state: " + state)
		
	elif(target_sus >= alert_thresh && target_sus < max_thresh):
		state = "alert"
		#print("state: " + state)
		
	elif(target_sus >= max_thresh):
		state = "maxed"
		#print("state: " + state)
		
	return state
	
