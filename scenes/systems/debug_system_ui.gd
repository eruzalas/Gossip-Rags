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
var att_state: String = ""
var att: float = 0.0
var action: float = 0.0
var tick: int = 24

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
			_are_sus()
			_determine_sus()
	if Input.is_action_just_pressed("ui_down"):
		if(steps > 0):
			steps -= 1
		#currently negates effects if attention is maxed in sus but given chnaged values this will change
		_are_sus() 
		_determine_sus()
		
	if Input.is_action_just_pressed("ui_right"):
		if(att < 10):
			action += 1
			print(action)
			_determine_atten()
	if Input.is_action_just_pressed("ui_left"):
		if(att > 0):
			action -= 1
		_determine_atten()
	
	#Decay, do not decay if there is nothing to decay
	if Input.is_action_just_pressed("ui_accept"):
		if(att > 0):
			action -= 0.5
		_determine_atten()
	
#Change Debug UI to show sus level and state
func _determine_sus():
	sus = suspicion_system._calculate_sus(multi, sus, steps)
	state = suspicion_system._state_level(sus)
	sus_debug.text = "Sus: " + str(sus) + " " + state
	
#Change Debug UI to show attention level and state
func _determine_atten():
	att = attention_system._calculate_att(action, att)
	att_state = attention_system._state_level(att)
	attention_debug.text = "Attention: " + str(att) + " " + att_state

#Ensure when attention state is "sus" the sus level increases
func _are_sus():
	if(att_state == "sus"):
		steps += 1
	
