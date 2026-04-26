#Script handles the maths of attention and the effects/state that occur
extends Node


#determined the current sus threshold
var state: String = ""
var att_level: float = 0  #int or float?
@export var reset_thresh: int
@export var sus_thresh: int

#Calculate attention to new total attention upon action--mutli=multiplier for costumes, actions=cost of attention action
#TODO fix maths
func _calculate_att(multi: float, action: float, current_att: float):
	att_level = (action * multi) + current_att
	return att_level

#Calculate current state level and updates state variable
func _state_level(att_precent: float):
	
	if(att_precent < reset_thresh):
		state = "base"
		print("astate: " + state)
	elif(att_precent >= reset_thresh && att_precent < sus_thresh):
		state = "reset"
		print("astate: " + state)
	elif(att_precent >= sus_thresh):
		state = "sus"
		print("astate: " + state)
		
	return state
	
#Natural decay of value dependant on state
func _natural_att_decay(att_precent: float):
	att_level = att_precent
	#TODO more proper math should be included here following amount of time past since last attention action
	att_level -= 1
	return att_level
