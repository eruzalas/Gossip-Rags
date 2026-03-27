#Script handles the maths of attention and the effects/state that occur
extends Node


#determined the current sus threshold
var state: String = ""
var att_level: float = 0  #int or float?

#Calculate attention to new total attention upon action
func _calculate_att(action: int, current_att: int):
	att_level = action				#current_att + action
	return att_level

#Calculate current state level and updates state variable
func _state_level(att_precent: float):
	
	if(att_precent < 3):
		state = "base"
		print("astate: " + state)
	elif(att_precent >= 3 && att_precent < 8):
		state = "reset"
		print("astate: " + state)
	elif(att_precent >= 8):
		state = "sus"
		print("astate: " + state)
		
	return state
	
#Natural decay of value dependant on state
func _natural_att_decay(att_precent: float):
	#state = _state_level(att_precent)
	att_level = att_precent
	#TODO more proper math should be included here following amount of time past since last attention action
	att_level -= 0.2
	print(att_level)
	return att_level
