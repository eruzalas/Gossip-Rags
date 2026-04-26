extends Control

#UI components
@onready var in_game_clock: Timer = %"InGame Clock"
@onready var clock_label: Label = %"Clock Label"
@onready var timeline: Control = %Timeline # CURRENTLY DOES NOTHING BUT WILL BE USED TO PASS VALUES TO THE TIMELINE

#Variables
var pause: bool = false
var clock_start: bool = false
var current_time: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	in_game_clock.one_shot = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	#Debugging/Testing code 
	#Check if the clock is paused, if not check if clock is running, if not then start clock else do nothing
	if(Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		if(!clock_start): 
			in_game_clock.start(30)
			clock_start = true
			
		if(pause):
			in_game_clock.start(current_time)
			pause = false
	
	#If clock is not paused, pause the clock and set variable to true
	if(Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)):
		if(!pause):
			in_game_clock.stop()
			pause = true
	
	if(!pause):
		_update_timer_label()

func _update_timer_label():
	current_time = in_game_clock.time_left
	clock_label.text = "Time: " + str(current_time)
