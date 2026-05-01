extends Area3D

#import data
@export var data: InteractionData

@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var sprite: Sprite3D = $Sprite3D

#stores reference to the specific player node
var current_player: Node3D = null
var is_active: bool = true 

func _on_body_entered(body: Node3D) -> void:
	if (body.is_in_group("players")):
		current_player = body

func _on_body_exited(body: Node3D) -> void:
	if (body.is_in_group("players")):
		current_player = null

func _unhandled_input(event: InputEvent) -> void:
	if is_active and current_player:
		if (event.is_action_pressed("p1_interact") or event.is_action_pressed("p2_interact")): #makes sure both players can interact
			_collect_item() #function to make it fall and disappear smoothly

func _collect_item():
	if not data:
		return
		
	is_active = false
	_fall_over()
	SignalBus.caused_attention.emit(current_player, data.attention_value)
	
	await get_tree().create_timer(0.6).timeout #lets the fall over animation finish before object poofs
	_disappear(false)
	
	#starts respawn timer 
	var timer = get_tree().create_timer(data.respawn_time)
	timer.timeout.connect(_respawn)
	
func _disappear(state: bool):
	sprite.visible = state
	collision_shape.set_deferred("disabled", !state) # set_deferred for collision ensures physics thread is ready

func _respawn():
	#force kills active tweens
	var tween = create_tween()
	tween.kill
	
	#reset rotations
	self.rotation_degrees = Vector3.ZERO
	sprite.rotation_degrees = Vector3.ZERO
	
	is_active = true
	_disappear(true)
	
func _fall_over():#really shitty tween animation
	var tween = create_tween()
	
	tween.tween_property(self, "rotation_degrees:x", -90, 0.6)\
		#thud effect ahh
		.set_trans(Tween.TRANS_BOUNCE)\
		.set_ease(Tween.EASE_OUT)
		
	
