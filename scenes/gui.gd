extends Control

#UI components
@onready var in_game_clock: Timer = %"InGame Clock"
@onready var clock_label: Label = %"Clock Label"
#@onready var timeline: Control = $Timeline  #Apparently will be used to pass variables to the timeline

#Variables
var pause: bool = false
var clock_start: bool = false
var current_time: int
@export var game_time: int


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	in_game_clock.one_shot = true
	
	#Listen for when the clock hits 0 then change scene
	in_game_clock.timeout.connect(_on_timeout)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	#Debugging/Testing code 
	#Check if the clock is paused, if not check if clock is running, if not then start clock else do nothing
	if(Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		if(!clock_start): 
			in_game_clock.start(game_time)
			clock_start = true

	_update_timer_label()
		
	
	

func _update_timer_label():
	current_time = in_game_clock.time_left
	clock_label.text = "Time: " + str(current_time)
	
func _on_timeout():
	get_tree().change_scene_to_file("res://scenes/level_stages/magazine.tscn")
