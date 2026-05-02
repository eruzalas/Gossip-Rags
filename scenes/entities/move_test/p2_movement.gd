extends CharacterBody3D

#---- Attach Inventory ----

#@export var player_inventory: inventory
@onready var player_inventory: inventory = preload("res://scenes/components/inventory/player2_inventory.tres")

#---- Movement Base Stats ----
var base_speed = 7
var move_speed = 0 #used to handle speed when running/crouching, inputs required
var jump_velocity = 000 #base is actually 10
var acceleration = 35
var deceleration = 30
var sprint_speed = 1 #increase above 1 to go faster when sprinting

#---- Stat Modifiers for Costumes ----
var speed_modifier: float
var jump_modifier: float
var accel_modifier: float
var decel_modifier: float

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
	if Input.is_action_just_pressed("p2_jump") and is_on_floor():
		velocity.y = (jump_velocity * jump_modifier)
	
	#handles input for dropping a costume and updating player stats afterwards
	if (Input.is_action_just_pressed("p2_drop")):
		drop(player_inventory.equipment[selected_costume])
		player_inventory.remove(selected_costume)
		update_stats()
		#$inventory_ui.update()
		update_sprite()
	
	if (Input.is_action_just_pressed("p2_interact") and costume_in_range and is_on_floor()):
		pickup()
	
	if (Input.is_action_just_pressed("cycle")):
		toggle_selected()
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("p2_left", "p2_right", "p2_up", "p2_down")

	if Input.is_action_pressed("p2_sprint") and !Input.is_action_pressed("p2_crouch"):
		move_speed = (base_speed * speed_modifier) * sprint_speed
	elif Input.is_action_pressed("p2_crouch") and !Input.is_action_pressed("p2_sprint"):
		move_speed = (base_speed * speed_modifier) * 0.75
	else :
		move_speed = (base_speed * speed_modifier)

	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		
		velocity.x = move_toward(velocity.x, direction.x * move_speed, (acceleration * accel_modifier) * delta)
		velocity.z = move_toward(velocity.z, direction.z * move_speed, (acceleration * accel_modifier) * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, (deceleration * decel_modifier) * delta)
		velocity.z = move_toward(velocity.z, 0, (deceleration * decel_modifier) * delta)
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
	dropped_item.global_position = $Marker3D.global_position
	dropped_item.item = item
	get_parent().add_child(dropped_item)
	print("dropping: "+ str(item.name))	

func toggle_selected():
	selected_costume += 1
	if (selected_costume >= player_inventory.size()):
		selected_costume = 0
	
##very badly assigns costumes based on a keyed ID system (ID = position in array)
func update_sprite():
	var sprite = ["p2_default","p2_banana","p2_motorbike","p2_pirate","p2_cat","p2_nurse","p2_cult","p2_dino","p2_ghost","p2_ninja","p2_angel","p2_horse"]
	var selected = 0 #
	for i in range (player_inventory.size()):
		if (!player_inventory.equipment[i]):
			pass
		else:
			selected = player_inventory.equipment[i].costume_ID
	if (selected >= sprite.size()):
		selected = 0
	$AnimatedSprite3D.animation = sprite[selected]
	
func _ready():
	$AnimatedSprite3D.animation = "p2_default"
	player_inventory.print()
	update_stats()
	update_sprite()
	print("-----")
	print("current speed: "+ str(base_speed * speed_modifier))
