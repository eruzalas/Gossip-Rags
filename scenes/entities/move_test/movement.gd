extends CharacterBody3D

#---- Attach Inventory ----

@export var player_inventory: inventory
#@onready var player_inventory: inventory = preload("res://scenes/components/inventory/player_inventory.tres")

#---- Movement Base Stats ----
var base_speed = 10
var move_speed = 0 #used to handle speed when running/crouching, inputs required
var jump_velocity = 000 #base is actually 10
var acceleration = 35
var deceleration = 30

#---- Stat Modifiers for Costumes ----
var speed_modifier: float
var jump_modifier: float
var accel_modifier: float
var decel_modifier: float

#---- Other Player Variables ----
var costume_in_range = []
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
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = (jump_velocity * jump_modifier)
	
	#handles input for dropping a costume and updating player stats afterwards
	if (Input.is_action_just_pressed("drop") and player_inventory.equipment[selected_costume]):
		drop(player_inventory.equipment[selected_costume])
		player_inventory.remove(selected_costume)
		update_stats()
		$inventory_ui.update()
		update_sprite()
	
	if (Input.is_action_just_pressed("interact") and costume_in_range and is_on_floor()):
		pickup()
	
	if (Input.is_action_just_pressed("cycle")):
		toggle_selected()
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	if Input.is_action_pressed("run") and !Input.is_action_pressed("crouch"):
		move_speed = (base_speed * speed_modifier) * 1.5
	elif Input.is_action_pressed("crouch") and !Input.is_action_pressed("run"):
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
	$inventory_ui.update()
	if (!is_empty):
		toggle_selected()
	update_sprite()
		
	
##"drops" an item by spawning a collectable with the same variables in the scene at the player's location
func drop(item: costume):
	var dropped_item = load("res://scenes/components/inventory/Costumes/costume_collectable.tscn").instantiate()
	dropped_item.global_position = $Marker3D.global_position
	dropped_item.item = item
	get_parent().add_child(dropped_item)	

func toggle_selected():
	selected_costume += 1
	if (selected_costume >= player_inventory.size()):
		selected_costume = 0
	
##very badly assigns costumes based on a keyed ID system (ID = position in array)
func update_sprite():
	var sprite = ["default","banana_costume","motorbike_helmet_costume"]
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
	player_inventory.print()
	update_stats()
	update_sprite()
	print("-----")
	print("current speed: "+ str(base_speed * speed_modifier))
