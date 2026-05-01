extends Area3D

#import data
@export var data: InteractionData
@export var slippery_duration:float = 3.0 #hard code as will only be used for this specific object

@onready var baby_oil_shape: CollisionShape3D = $CollisionShapeBabyOil
@onready var puddle_shape: CollisionShape3D = $CollisionShapePuddle
@onready var sprite: Sprite3D = $BabyOil #diddy placeholder
@onready var puddle: Sprite3D = $PuddleSprite #flat sprite on floor

#stores reference to the specific player node
var players_in_range: Array[Node3D] = [] #if both players are in spill, both get affected
var is_active: bool = true
var is_slippery: bool = false

func _ready():
	puddle.hide()
	puddle_shape.disabled = true
	baby_oil_shape.disabled = false

func _on_body_entered(body: Node3D) -> void:
	if (body.is_in_group("players") and not players_in_range.has(body)):
		players_in_range.append(body)
		# if floor is already oily, make new player entering slip
		if is_slippery:
			_set_player_slippery(body, true)

func _on_body_exited(body: Node3D) -> void:
	if (players_in_range.has(body)):
		_set_player_slippery(body, false)
		players_in_range.erase(body)

func _unhandled_input(event: InputEvent) -> void:
	#checks which player pressed and caused the fall
	for p in players_in_range:
		var p_name = p.name 
		var action = "p1_interact" if p_name == "Player1" else "p2_interact"
	
		if event.is_action_pressed(action): #makes sure both players can interact
			_trigger_spill(p) #pass specific player that caused it
			break

func _trigger_spill(causer: Node3D):
	is_active = false
	is_slippery = true
	_fall_over()
	SignalBus.caused_attention.emit(causer, data.attention_value)
	
	#change collision shape so that it matches oil spill shape
	baby_oil_shape.set_deferred("disabled", true)
	puddle_shape.set_deferred("disabled", false)
	
	puddle.show()
	# All players that are in the puddle should slip
	for p in players_in_range:
		_set_player_slippery(p, true)
	
	#lets the fall over animation finish before object poofs
	await get_tree().create_timer(0.6).timeout 
	sprite.hide() 
	
	#timer for spill effect
	get_tree().create_timer(slippery_duration).timeout.connect(_on_oil_dry)
	
	#starts respawn timer 
	var timer = get_tree().create_timer(data.respawn_time)
	timer.timeout.connect(_respawn)

func _on_oil_dry():
	is_slippery = false
	puddle.hide()
	#turn off puddle collision to stop slips
	puddle_shape.set_deferred("disabled", true)
	
	for p in players_in_range:
		_set_player_slippery(p, false)

func _set_player_slippery(p: Node3D, state: bool):
	if (p.has_method("set_slippery")):
		p.set_slippery(state)

func _respawn():
	#force kills active tweens
	var tween = create_tween()
	tween.kill
	
	#reset rotations
	self.rotation_degrees = Vector3.ZERO
	sprite.rotation_degrees = Vector3.ZERO
	
	is_active = true
	sprite.show()
	baby_oil_shape.set_deferred("disabled", false)
	
func _fall_over():#really shitty tween animation
	var tween = create_tween()
	
	tween.tween_property(sprite, "rotation_degrees:x", -90, 0.6)\
		#thud effect ahh
		.set_trans(Tween.TRANS_BOUNCE)\
		.set_ease(Tween.EASE_OUT)
		
	
