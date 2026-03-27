#Script does the calculations and is a node components can hold
extends Node

#determined the current sus threshold
var state: String = ""
var sus_level: float = 0  #int or float?

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

#Calculate suspicion precentage (accounts for costume multipliers and "steps" how long in sus)
func _calculate_sus(multi: float, sus_precent: float, steps: int):
	
	sus_level = (sus_precent + steps) * multi
	return sus_level

#Calculate current state level and updates state variable
func _state_level():
	
	if(sus_level < 50):
		state = "calm"
		print("state: " + state)
	elif(sus_level > 50 && sus_level < 80):
		state = "wary"
		print("state: " + state)
	elif(sus_level > 80):
		state = "alert"
		print("state: " + state)
		
	return state
