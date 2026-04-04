extends CharacterBody3D

class_name Npc

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var test_display_text: MeshInstance3D = $"Test Display Text"
@onready var player = get_tree().get_first_node_in_group("players")
@onready var range_of_effect: Area3D = $"Range of Effect"
@onready var look_timer: Timer = $"Look Timer"
@onready var sprite_3d: Sprite3D = $Sprite3D

@export var group_origin_ID: int = 0
@export var npc_type: String = "stationary"

var min_look_time_elapsed: float = 5.0
var max_look_time_elapsed: float = 10.0

var parent_origin
var at_target: bool = true
var has_active_target: bool = false

var player_in_range: bool = false
var looking_at_entity: bool = false
var target_look_position: Vector3 = Vector3.ZERO

var must_move: bool = false

const SPEED = 2.0

func _ready():
	nav_agent.velocity_computed.connect(Callable(_on_navigation_agent_3d_velocity_computed))
	add_to_group("npcs")
	sprite_3d.texture = load(ResourcePaths.npc_icon_path + npc_type + ".png")

func _set_npc_type(type:String) -> void:
	npc_type = type
	sprite_3d.texture = load(ResourcePaths.npc_icon_path + npc_type + ".png")

# https://docs.godotengine.org/en/stable/tutorials/navigation/navigation_using_navigationagents.html#navigationagent-pathfinding 
#changing this later
func set_movement_target(movement_target: Vector3):
	nav_agent.set_target_position(movement_target)

func _physics_process(delta: float) -> void:
	if not looking_at_entity:
		_on_look_timer_timeout()
		
	# check if NPC is within origin range, if not, pathfind into range
	
	#if global_position.distance_to(get_parent().global_position) > get_parent().collision_shape_3d.shape.radius || must_move:
	#	if not has_active_target:
	#		set_movement_target(get_parent()._get_random_position_in_annulus())
	#		has_active_target = true
	#		must_move = false
	#else:
	#	has_active_target = false
		
	if must_move:
		set_movement_target(get_parent()._get_random_position_in_annulus(true))
		has_active_target = true
		must_move = false
		
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

func _on_look_timer_timeout() -> void:
	target_look_position = _get_random_entity_pos_in_area()
	look_timer.start(randf_range(min_look_time_elapsed, max_look_time_elapsed))
