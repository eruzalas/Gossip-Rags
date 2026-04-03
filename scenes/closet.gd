extends CSGCombiner3D

@onready var interaction_label = %ClosetInteractLabel
var player_in_range = false
var is_open = false

func _ready():
	interaction_label.hide() #hides the label at the start 

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("players"): #checks if the entity that entered is in the players group
		player_in_range = true
		interaction_label.show()


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("players"):
		player_in_range = false
		interaction_label.hide()


func _on_area_3d_2_body_entered(body: Node3D) -> void:
	if body.is_in_group("players"): 
		player_in_range = true
		interaction_label.show()


func _on_area_3d_2_body_exited(body: Node3D) -> void:
	if body.is_in_group("players"):
		player_in_range = false
		interaction_label.hide()
		
func _unhandled_input(event: InputEvent) -> void:
	if player_in_range and event.is_action_pressed("interact"): #checks input map if the key mapped to interact is pressed
		_toggle_closet()
		
func _toggle_closet():
	#will use Tween for now to animate 
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	if is_open:
		tween.tween_property(%closet_door_left, "rotation_degrees:y", 0, 0.6)
		tween.tween_property(%closet_door_right, "rotation_degrees:y", 0, 0.6) #this one goes back to when its closed
	else: 
		tween.tween_property(%closet_door_left, "rotation_degrees:y", -90, 0.6)
		tween.tween_property(%closet_door_right, "rotation_degrees:y", 90, 0.6) #this one is the open position
	is_open = !is_open
