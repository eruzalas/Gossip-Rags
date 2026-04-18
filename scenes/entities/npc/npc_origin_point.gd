extends Area3D

class_name OriginPoint

@export var is_active: bool = false
@export var group_origin_ID: int = 0
@export var gen_NPC_number: int = 2
@export var max_NPC_number: int = 4
@export var base_movement_chance: float = 0.5
@export var time_elapse_minimum: int = 5

const npc_prefab = preload("res://scenes/entities/npc/npc.tscn")
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var player: CharacterBody3D = get_node("/root/World/Player1")
@onready var movement_opportunity_timer: Timer = $"Movement Opportunity Timer"

var movement_opportunity_flag: bool = false
var child_npcs: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	
	if is_active:
		var i = 0
		while i < gen_NPC_number:
			var new_npc = npc_prefab.instantiate()
			# https://forum.godotengine.org/t/create-node-at-random-position-in-area-3d/830/2
			add_child(new_npc)
			child_npcs.append(new_npc)
			
			var valid_position_set = false
			var iteration_counter = 0
			var random_position
			# check position before setting - to reduce issues with NPC position being too close to another
			while valid_position_set != true:
				if iteration_counter > 10:
					print("Failed to find appropriate location in 10 iterations.")
					valid_position_set = true
					
				random_position = collision_shape_3d.global_position + _get_random_position_in_annulus()
				if !_is_position_colliding_with_children(random_position):
					valid_position_set = true
					
				iteration_counter += 1
				
			new_npc.global_position = collision_shape_3d.global_position + _get_random_position_in_annulus()
			new_npc._set_npc_type("group")
			i += 1
			
		movement_opportunity_timer.start(_generate_timeout_period())
	

func _is_position_colliding_with_children(unchecked_position: Vector3) -> bool:
	for child in child_npcs:
		if child.global_position.distance_to(unchecked_position) < 1.5:
			return true
	return false

func _check_movement_opportunity_status():
	return movement_opportunity_flag

func _generate_timeout_period():
	# retrieve suspicion/attention values - hardcoded for sake of testing
	var suspicion = 9
	var max_suspicion = 10
	#var timeout = 10 + (10 / (1 - (suspicion / max_suspicion)))
	var timeout = 2
	return timeout
	
func _refresh_movement_opportunity_timer():
	movement_opportunity_flag = false
	movement_opportunity_timer.start(_generate_timeout_period())

func _process(_delta: float) -> void:
	pass

# if timeout - post flag active - controller checks this
# this doesnt follow pattern correctly lmfao i need to fix it
# TODO: as above lmao
func _on_movement_opportunity_timer_timeout() -> void:
	movement_opportunity_flag = true
	
# get children
func _get_child_npcs() -> void:
	child_npcs.clear()
	for child in get_children():
		if child is Npc:
			child_npcs.append(child)
			

# gets selected child, reparents it and then gives it a target
func _tell_child_to_move(destination):
	var selected_child = child_npcs[randi_range(0, child_npcs.size() - 1)]
	selected_child.reparent(destination)
	selected_child._get_new_target_position()
	# get_child called again to ensure child list is up to date
	# TODO: I feel there is a better way to do this - ill look into ts later
	_get_child_npcs()
	destination._get_child_npcs()

# source: https://stackoverflow.com/questions/5837572/generate-a-random-point-within-a-circle-uniformly/50746409#50746409
# and: https://codepen.io/KonradLinkowski/pen/ExjLGxJ
func _get_random_position_in_annulus(include_own_position:bool = false):
	var x_offset: float = 1.0
	var z_offset: float = 1.0
	
	if include_own_position:
		x_offset = global_position.x
		z_offset = global_position.z
	
	const spawn_inner_radius = 1
	# outer_radius by which NPCs will spawn within (reduce this if you want them further within radius)
	var spawn_outer_radius = collision_shape_3d.shape.radius - 0.5
	
	var r = sqrt(randf() * (spawn_outer_radius**2 - spawn_inner_radius**2) + spawn_inner_radius**2)
	var theta = randf() * 2 * PI
	
	var x = x_offset + r * cos(theta)
	var y = 1
	var z = z_offset + r * sin(theta)
	
	return Vector3(x, y, z)
	
