extends Control

#Nodes that will be changed upon player input
@onready var ready_1_set: RichTextLabel = $"Ready 1 set"
@onready var ready_2_set: RichTextLabel = $"Ready 2 set"
@onready var play_button: TextureButton = $"Play Button"

#Additional variables needed for checks and assignments
var p1_ready: bool = false
var p2_ready: bool = false
var ready_text: String = "[wave amp=50 freq=2][rainbow freq=0.05 sat=10 val=20][font_size=24][center][b]Ready[/b][/center][/font_size][/rainbow][/wave]"
var not_ready_text: String = "[wave amp=50 freq=2][rainbow freq=0.05 sat=10 val=20][font_size=24][center][b]Not Ready[/b][/center][/font_size][/rainbow][/wave]"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	#Player Input for ready state
	if (Input.is_action_just_pressed("p1_up")):
		p1_ready = true
		ready_1_set.text = ready_text
	
	if (Input.is_action_just_pressed("p1_down")):
		p1_ready = false
		ready_1_set.text = not_ready_text
		
	if (Input.is_action_just_pressed("p2_up")):
		p2_ready = true
		ready_2_set.text = ready_text
		
	if (Input.is_action_just_pressed("p2_down")):
		p2_ready = false
		ready_2_set.text = not_ready_text
		
	#Check if both players are ready and allow the button to be pressed
	if (p1_ready && p2_ready):
		play_button.disabled = false
	else:
		play_button.disabled = true
		
