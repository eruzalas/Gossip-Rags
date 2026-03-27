extends Node

#System nodes (components)
@onready var suspicion_system: Node = %"Suspicion System"
@onready var attention_system: Node = %"Attention System"

#UI components
@onready var sus_debug: Label = %"Sus Debug"
@onready var attention_debug: Label = %"Attention Debug"

#addtional variables --> Will need adjustment with costumes/players and such to demonstrate debug stats
var sus: float = 0.0
var multi: float = 1.0
var steps: int = 0 #changes per second of time spent in suspicion
var state: String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Current function operates with button presses
func _process(delta: float) -> void:
	
	#Debugging/Testing code 
	if Input.is_action_just_pressed("ui_up"):
		if(steps < 10):
			steps += 1
			print(steps)
			_determine_sus()
	if Input.is_action_just_pressed("ui_down"):
		if(steps > 0):
			steps -= 1
		_determine_sus()
	
	
func _determine_sus():
	sus = suspicion_system._calculate_sus(multi, sus, steps)
	state = suspicion_system._state_level(sus)
	sus_debug.text = "Sus: " + str(sus) + " " + state
	pass
