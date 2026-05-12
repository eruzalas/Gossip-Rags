#Script does the calculations and is a node components can hold
extends Node

#determined the current sus threshold
var state: String = ""
var sus_level: float = 0  #int or float?
@export var wary_thresh: int
@export var alert_thresh: int
@export var max_thresh: int

#Calculate suspicion precentage (accounts for costume multipliers and "steps" how long in sus)
#TODO: Work on maths
func _calculate_sus_general(multi: float, sus_precent: float, steps: float):
	sus_level = sus_precent
	sus_level += (steps/2) * multi
	return sus_level
	
#Adds to the sus meter a static amount -- effected by costume
#TODO: Sort out maths
func _sudden_sus_boost(multi: float, sus_precent: float, action: float):
	sus_level = sus_precent
	sus_level += action * multi
	return sus_level

#Calculate current state level and updates state variable
func _state_level(sus_precent: float):
	
	if(sus_precent < wary_thresh):
		state = "calm"
		#print("state: " + state)
	elif(sus_precent >= wary_thresh && sus_precent < alert_thresh):
		state = "wary"
		#print("state: " + state)
	elif(sus_precent >= alert_thresh && sus_precent < max_thresh):
		state = "alert"
		#print("state: " + state)
	elif(sus_precent >= max_thresh):
		state = "maxed"
		#print("state: " + state)
		
	return state
	
#Decay for suspicion
#TODO: Sort out maths
func _sus_decay(sus_precent: float):
	sus_level = sus_precent
	if(sus_level > 0):
		sus_level -= 1
	return sus_level
