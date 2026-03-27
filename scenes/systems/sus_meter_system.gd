#Script does the calculations and is a node components can hold
extends Node

#determined the current sus threshold
var state: String = ""
var sus_level: float = 0  #int or float?

#Calculate suspicion precentage (accounts for costume multipliers and "steps" how long in sus)
func _calculate_sus(multi: float, sus_precent: float, steps: int):
	
	sus_level = (steps) * multi  #should have the current sus influence this for exponential
	return sus_level

#Calculate current state level and updates state variable
func _state_level(sus_precent: float):
	
	if(sus_precent < 5):
		state = "calm"
		print("state: " + state)
	elif(sus_precent >= 5 && sus_precent < 8):
		state = "wary"
		print("state: " + state)
	elif(sus_precent >= 8 && sus_precent < 10):
		state = "alert"
		print("state: " + state)
	elif(sus_precent >= 10):
		state = "maxed"
		print("state: " + state)
		
	return state
