extends CharacterBody3D
class_name Npc

# -- references --
# external to NPC
@onready var player = get_tree().get_first_node_in_group("players")
@onready var navigation_region_3d: NavigationRegion3D = $"../NavigationRegion3D"

# internal to NPC
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var test_display_text: MeshInstance3D = $"Test Display Text"
@onready var range_of_effect: Area3D = $"Range of Effect"
@onready var sprite: Sprite3D = $Sprite
@onready var look_timer: Timer = $"Look Timer"
@onready var wander_timer: Timer = $"Wander Timer"

# export vars
@export var npc_type: String = "stationary"
@export var npc_allowed_zone_layers: Array[int] = []

var min_look_time_elapsed: float = 5.0
var max_look_time_elapsed: float = 10.0

var min_wander_wait: float = 5.0
var max_wander_wait: float = 10.0

var has_active_target: bool = false

var player_in_range: bool = false
var looking_at_entity: bool = false
var target_look_position: Vector3 = Vector3.ZERO

const SPEED = 3.0

func _ready():
	nav_agent.velocity_computed.connect(Callable(_on_navigation_agent_3d_velocity_computed))
	add_to_group("npcs")
	sprite.texture = load(ResourcePaths.npc_icon_path + npc_type + ".png")
	if npc_type.contains("wander"):
		wander_timer.start(_generate_wander_wait())

func _set_npc_type(type:String) -> void:
	npc_type = type
	sprite.texture = load(ResourcePaths.npc_icon_path + npc_type + ".png")

# https://docs.godotengine.org/en/stable/tutorials/navigation/navigation_using_navigationagents.html#navigationagent-pathfinding 
#changing this later
func _set_movement_target(movement_target: Vector3):
	nav_agent.set_target_position(movement_target)

func _npc_must_move():
	if npc_type == "group":
		_set_movement_target(get_parent()._get_random_position_in_annulus(true))
	elif npc_type.contains("wander"):
		var world = get_world_3d().navigation_map
		var nav_layer = 1
		if npc_type == "wander_zone":
			# note: when setting nav layers for wandering, the layer number is equiv to 2^(layer index FROM ZERO)
				# adding multiple layers involve taking the original calculated layer and ADDING THEM TOGETHER
				# ie. nav layer for layer 1 = 2^0 => 1
				# ie. nav layer for layer 2 = 2^1 => 2
				# ie. nav layer for layer 3 = 2^2 => 4
				# ie. nav layer for layer 1, 2 and 3 = 1+2+4 => 7
			# just consider nav layer as binary bits - but for ease of use ive added the export array to do calculations here instead
			if !npc_allowed_zone_layers.is_empty():
				nav_layer = 0
				for value in npc_allowed_zone_layers:
					nav_layer += pow(2, (value - 1))
					
		var random_location = NavigationServer3D.map_get_random_point(world, nav_layer, true)
		_set_movement_target(random_location)
	has_active_target = true

func _physics_process(delta: float) -> void:
	if not looking_at_entity:
		_on_look_timer_timeout()
		
	# check if NPC is within origin range, if not, pathfind into range
	
	#if global_position.distance_to(get_parent().global_position) > get_parent().collision_shape_3d.shape.radius || must_move:
	#	if not has_active_target:
	#		_set_movement_target(get_parent()._get_random_position_in_annulus())
	#		has_active_target = true
	#		must_move = false
	#else:
	#	has_active_target = false
		
	if has_active_target:
		# Do not query when the map has never synchronized and is empty.
		if NavigationServer3D.map_get_iteration_id(nav_agent.get_navigation_map()) == 0:
			return
		if nav_agent.is_navigation_finished():
			has_active_target = false
			return

		var next_pos: Vector3 = nav_agent.get_next_path_position()
		var direction: Vector3 = global_position.direction_to(next_pos) * SPEED
		var new_velocity: Vector3 = velocity + (direction - velocity)
		
		nav_agent.set_velocity(new_velocity)
		
		_look_at_position(next_pos, delta, 3.0)
		
		#if navigation_agent_3d.avoidance_enabled:
		#	navigation_agent_3d.set_velocity(new_velocity)
		#else:
		#	_on_navigation_agent_3d_velocity_computed(new_velocity)
	else:
		if player_in_range:
			_look_at_position(player.global_transform.origin, delta, 3.0)
		else:
			_look_at_position(target_look_position, delta, 3.0)

func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = safe_velocity
	move_and_slide()


func _on_range_of_effect_body_entered(body: Node3D) -> void:
	if body.is_in_group("players"):
		test_display_text.visible = true
		player_in_range = true


func _on_range_of_effect_body_exited(body: Node3D) -> void:
	if body.is_in_group("players"):
		test_display_text.visible = false
		player_in_range = false

func _flatten_look_y(target_position):
	target_position.y = global_position.y
	return target_position

func _get_random_entity_pos_in_area():
	var entity_position: Vector3 = Vector3.ZERO
	if range_of_effect.has_overlapping_bodies():
		var entities_in_range = range_of_effect.get_overlapping_bodies()
		entities_in_range.erase(self)
		if entities_in_range.size() > 0:
			looking_at_entity = true
			entity_position = entities_in_range[randi_range(0, entities_in_range.size() - 1)].global_transform.origin
	
	if entity_position == Vector3.ZERO:
		entity_position = get_parent().global_transform.origin
	return entity_position

# source: https://forum.godotengine.org/t/slowly-interpolate-look-at-function-for-my-enemy/100750
func _look_at_position(target_position: Vector3, delta: float, turn_speed: float) -> void:
	var target_vector := target_position - global_position

	if not target_vector.length():
		return

	var target_rotation := lerp_angle(
		global_rotation.y,
		atan2(target_vector.x, target_vector.z),
		turn_speed * delta
	)
	global_rotation.y = target_rotation

func _generate_wander_wait():
	# maybe add calculation off suspicion/attention?
	return randf_range(min_wander_wait, max_wander_wait)


func _on_look_timer_timeout() -> void:
	target_look_position = _get_random_entity_pos_in_area()
	look_timer.start(randf_range(min_look_time_elapsed, max_look_time_elapsed))
	
func _on_wander_timer_timeout() -> void:
	_npc_must_move()
	wander_timer.start(_generate_wander_wait())
