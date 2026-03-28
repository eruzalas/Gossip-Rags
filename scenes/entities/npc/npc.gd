extends CharacterBody3D

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D

@export var group_origin_ID: int = 0

var parent_origin
var at_target: bool = true
var has_active_target: bool = true

const SPEED = 5.0

func _ready():
	navigation_agent_3d.velocity_computed.connect(Callable(_on_navigation_agent_3d_velocity_computed))

# https://docs.godotengine.org/en/stable/tutorials/navigation/navigation_using_navigationagents.html#navigationagent-pathfinding 
#changing this later
func set_movement_target(movement_target: Vector3):
	navigation_agent_3d.set_target_position(movement_target)

func _physics_process(delta: float) -> void:
	# check if NPC is within origin range, if not, pathfind into range
	
	if not has_active_target:
		var npc_distance = global_position.distance_to(get_parent().global_position)
		#print(npc_distance)
		if npc_distance > get_parent().collision_shape_3d.shape.radius:
			has_active_target = true
			set_movement_target(get_parent()._get_random_position_in_radius())
		
	
	# Do not query when the map has never synchronized and is empty.
	if NavigationServer3D.map_get_iteration_id(navigation_agent_3d.get_navigation_map()) == 0:
		return
	if navigation_agent_3d.is_navigation_finished():
		return

	var next_path_position: Vector3 = navigation_agent_3d.get_next_path_position()
	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * SPEED
	if navigation_agent_3d.avoidance_enabled:
		navigation_agent_3d.set_velocity(new_velocity)
	else:
		_on_navigation_agent_3d_velocity_computed(new_velocity)

#	move_and_slide()


func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = safe_velocity
	move_and_slide()
