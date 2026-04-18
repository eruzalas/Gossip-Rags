extends Control

#Progress bar nodes
@onready var tea_bar_1: TextureProgressBar = $"Tea Bar 1"
@onready var tea_bar_2: TextureProgressBar = $"Tea Bar 2"
@onready var tea_bar_3: TextureProgressBar = $"Tea Bar 3"
@onready var tea_bar_4: TextureProgressBar = $"Tea Bar 4"
@onready var tea_bar_5: TextureProgressBar = $"Tea Bar 5"
@onready var tea_bar_6: TextureProgressBar = $"Tea Bar 6"
@onready var tea_bar_7: TextureProgressBar = $"Tea Bar 7"
@onready var tea_bar_8: TextureProgressBar = $"Tea Bar 8"

#Additional variables
var bar_a_num: int  # may need to be changed later for this to be a variable recieved from other scripts
@export var tea_bar_array: Array[TextureProgressBar]

# When the game begins set all the progress bars values to 0
func _ready() -> void:
	print("Number in tea array " + str(tea_bar_array.size()))
	for tea in tea_bar_array:
		tea.value == tea.min_value
		print("PROG IS " +  str(tea.value))

# Update the indiviual progress bars
func _process(delta: float) -> void:
	
	#Debugging/Testing code 
	if Input.is_key_pressed(KEY_1): # 1 on keyboard
		bar_a_num = 0
		_update_progress_bar()
	if Input.is_key_pressed(KEY_2): # 2 on keyboard
		bar_a_num = 1
		_update_progress_bar()
	if Input.is_key_pressed(KEY_3): # 3 on keyboard
		bar_a_num = 2
		_update_progress_bar()
	if Input.is_key_pressed(KEY_4): # 4 on keyboard
		bar_a_num = 3
		_update_progress_bar()
	if Input.is_key_pressed(KEY_5): # 5 on keyboard
		bar_a_num = 4
		_update_progress_bar()
	if Input.is_key_pressed(KEY_6): # 6 on keyboard
		bar_a_num = 5
		_update_progress_bar()
	if Input.is_key_pressed(KEY_7): # 7 on keyboard
		bar_a_num = 6
		_update_progress_bar()
	if Input.is_key_pressed(KEY_8): # 8 on keyboard
		bar_a_num = 7
		_update_progress_bar()
	if Input.is_key_pressed(KEY_0): # 0 on keyboard
		_reset_prog_bars()
	
# Use bar_a_num variable to grab the correct node from the array and then add 1 to the value
func _update_progress_bar():
	var tea = tea_bar_array[bar_a_num]
	tea.value += 1

# Reset all the bars to 0 FOR DEBUG PURPOSES CURRENTLY
func _reset_prog_bars():
	for tea in tea_bar_array:
		tea.value = 0
		
#TODO: Make a way for it to increase backwards mahaps?? like an actual timeline
	
