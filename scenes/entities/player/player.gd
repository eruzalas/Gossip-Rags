extends CharacterBody3D

class_name Player

@onready var marker_3d: Marker3D = $Marker3D
@onready var player_sprite: AnimatedSprite3D = $AnimatedSprite3D

@export var player_ID: Enums.PlayerType
var str_ID: String

#---- Attach Inventory ----
const player_inventories: Array = [preload("res://scenes/components/inventory/player_inventory.tres"), preload("res://scenes/components/inventory/player2_inventory.tres")]
var player_inventory

#---- Movement Base Stats ----
const BASE_SPEED = 7
const JUMP_VELOCITY = 000 #base is actually 10
const ACCELERATION = 35
const DECELERATION = 30
const SPRINT_SPEED = 1 #increase above 1 to go faster when sprinting

#---- Stat Modifiers for Costumes ----
var speed_modifier: float
var jump_modifier: float
var accel_modifier: float
var decel_modifier: float

#---- Movement Runtime Updated Stats ----
var move_speed = 0 #used to handle speed when running/crouching, inputs required

#---- Other Player Variables ----
##array for storing costumes in interactable range, used to avoid multiplayer issues
var costume_in_range = []

#unfinished toggle for selecting a costume if multiple are equipped, idea is to be able to choose which one is dropped
var selected_costume = 0

#currently just a player identifier
func player():
	pass

##applies stats from inventory items (multiplicative if several items present)
func update_stats():
	var temp_speed = 1
	var temp_jump = 1
	var temp_accel = 1
	var temp_decel = 1
	for i in range (player_inventory.size()):
		if (!player_inventory.equipment[i]):
			pass
		else:
			temp_speed *= player_inventory.equipment[i].speed_modifier
			temp_jump *= player_inventory.equipment[i].jump_height_modifier
			temp_accel *= player_inventory.equipment[i].accel_modifier
			temp_decel *= player_inventory.equipment[i].decel_modifier
	speed_modifier = temp_speed
	jump_modifier = temp_jump
	accel_modifier = temp_accel
	decel_modifier = temp_decel


#---- Actual Controls /w physics ----
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# Handle jump.
	if Input.is_action_just_pressed("p%s_jump" % str_ID) and is_on_floor():
		velocity.y = (JUMP_VELOCITY * jump_modifier)
	
	#handles input for dropping a costume and updating player stats afterwards
	if (Input.is_action_just_pressed("p%s_drop" % str_ID)):
		drop(player_inventory.equipment[selected_costume])
		player_inventory.remove(selected_costume)
		update_stats()
		#$inventory_ui.update()
		update_sprite()
	
	if (Input.is_action_just_pressed("p%s_interact" % str_ID) and costume_in_range and is_on_floor()):
		pickup()
	
	if (Input.is_action_just_pressed("cycle")):
		toggle_selected()
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("p%s_left" % str_ID, "p%s_right" % str_ID, "p%s_up" % str_ID, "p%s_down" % str_ID)

	if Input.is_action_pressed("p%s_sprint" % str_ID) and !Input.is_action_pressed("p%s_crouch" % str_ID):
		move_speed = (BASE_SPEED * speed_modifier) * SPRINT_SPEED
	elif Input.is_action_pressed("p%s_crouch" % str_ID) and !Input.is_action_pressed("p%s_sprint" % str_ID):
		move_speed = (BASE_SPEED * speed_modifier) * 0.75
	else :
		move_speed = (BASE_SPEED * speed_modifier)

	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		
		velocity.x = move_toward(velocity.x, direction.x * move_speed, (ACCELERATION * accel_modifier) * delta)
		velocity.z = move_toward(velocity.z, direction.z * move_speed, (ACCELERATION * accel_modifier) * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, (DECELERATION * decel_modifier) * delta)
		velocity.z = move_toward(velocity.z, 0, (DECELERATION * decel_modifier) * delta)
	move_and_slide()

##called to pickup costumes stored in costumes_in_range
func pickup():
	var is_empty = true
	if(!costume_in_range[0]):
		return
	if(player_inventory.equipment[0]):
		is_empty = false
	var new_costume = costume_in_range[0]
	var old_costume = player_inventory.equip(new_costume.item, selected_costume) #equips the new item and returns the old one
	if (old_costume): #if an item has to be dropped, player needs to spawn it
		drop(old_costume)
	new_costume.remove()
	update_stats()
	#$inventory_ui.update() #debug UI, not really important (also unfinished lol)
	if (!is_empty):
		toggle_selected()
	update_sprite()
		
	
##"drops" an item by spawning a collectable with the same variables in the scene at the player's location
func drop(item: costume):
	if (!item):
		return
	var dropped_item = load("res://scenes/components/inventory/Costumes/costume_collectable.tscn").instantiate()
	dropped_item.global_position = marker_3d.global_position
	dropped_item.item = item
	get_parent().add_child(dropped_item)
	print("dropping: "+ str(item.name))	

func toggle_selected():
	selected_costume += 1
	if (selected_costume >= player_inventory.size()):
		selected_costume = 0
	
##very badly assigns costumes based on a keyed ID system (ID = position in array)
func update_sprite():
	var sprite_postfix = ["_default","_banana","_motorbike","_pirate","_cat","_nurse","_cult","_dino","_ghost","_ninja","_angel","_horse"]
	var sprite = []
	
	for postfix in sprite_postfix:
		sprite.append("p" + str_ID + postfix)
	
	#var sprite = ["p2_default","p2_banana","p2_motorbike","p2_pirate","p2_cat","p2_nurse","p2_cult","p2_dino","p2_ghost","p2_ninja","p2_angel","p2_horse"]
	var selected = 0 #
	for i in range (player_inventory.size()):
		if (!player_inventory.equipment[i]):
			pass
		else:
			selected = player_inventory.equipment[i].costume_ID
	if (selected >= sprite.size()):
		selected = 0
	player_sprite.animation = sprite[selected]
	
func _ready():
	player_inventory = player_inventories[player_ID]
	str_ID = str(player_ID + 1)
	player_sprite.animation = "p%s_default" % str_ID
	player_inventory.print()
	update_stats()
	update_sprite()
	print("-----")
	print("current speed: "+ str(BASE_SPEED * speed_modifier))


func _on_listening_range_body_entered(body: Node3D) -> void:
	if body is Npc:
		body.in_listening_range = true

func _on_listening_range_body_exited(body: Node3D) -> void:
	if body is Npc:
		body.in_listening_range = false
