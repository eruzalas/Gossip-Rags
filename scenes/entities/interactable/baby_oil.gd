extends Area3D

#stores reference to the specific player node
var current_player: Node3D = null

func _on_body_entered(body: Node3D) -> void:
	if (body.is_in_group("players")):
		current_player = body
		print("Valid Player detected")
	

func _on_body_exited(body: Node3D) -> void:
	if (body.is_in_group("players")):
		current_player = null

func _unhandled_input(event: InputEvent) -> void:
	if current_player:
		if (event.is_action_pressed("p1_interact") or event.is_action_pressed("p2_interact")): #makes sure both players can interact
			print("DEBUG: Interactable emit signal")
			
			#pass the curent player and attention value as (5.0)
			SignalBus.caused_attention.emit(current_player, 5.0)
			_fall_over()
func _fall_over():#really shitty tween animation
	var tween = create_tween()
	
	tween.tween_property(self, "rotation_degrees:x", -90, 0.6)\
		#thud effect ahh
		.set_trans(Tween.TRANS_BOUNCE)\
		.set_ease(Tween.EASE_OUT)
		
	
