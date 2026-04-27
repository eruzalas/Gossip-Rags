extends Control
@onready var pause_menu: Control = $"."

#when the game begins hide the menu
func _ready() -> void:
	pause_menu.visible = false
	
# Look to see if esc has been pressed
func _process(delta: float) -> void:
	
	if(Input.is_action_just_pressed("pause")):
		press_pause()
	
	
#When resume is paused continue the game
func resume():
	get_tree().paused = false
	pause_menu.visible = false
	
func pause():
	get_tree().paused = true
	pause_menu.visible = true

#when esc is pressed it will pause the game or resume the game depending if menu is open
func press_pause():
	#if the scene is not paused pause the game
	if(Input.is_action_just_pressed("pause") && !get_tree().paused):
		pause()
	#else if the scene is paused resume the game
	elif(Input.is_action_just_pressed("pause") && get_tree().paused):
		resume()
		

#button functions
#resume the game
func _on_resume_pressed() -> void:
	resume()
	print("Game is resumed")

#quit the scene
func _on_quit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

#Code to restart the game
#func _restart() -> void:
#	get_tree().paused = false
#	get_tree().reload_current_scene()
