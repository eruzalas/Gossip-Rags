extends CharacterBody3D
class_name Npc

# some of the code in _set_movement_target and _process was taken from the following source:
	# https://docs.godotengine.org/en/stable/tutorials/navigation/navigation_using_navigationagents.html#navigationagent-pathfinding 

# -- references --
# external to NPC
@onready var player = get_tree().get_first_node_in_group("players")

# internal to NPC
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var text_display: MeshInstance3D = $"Test Display Text"
@onready var bangarang_range: Area3D = $"Bangarang Range"
@onready var attention_range: Area3D = $"Attention Range"
@onready var sprite: Sprite3D = $Sprite
@onready var look_timer: Timer = $"Look Timer"
@onready var wander_timer: Timer = $"Wander Timer"
@onready var dialogue_renderer: Sprite3D = $DialogueRenderer
@onready var gossiper_component: Node = $GossiperComponent

# export vars
@export var debug_mode: bool = true

@export_group("Type")
@export var npc_type: Enums.NpcType = Enums.NpcType.STATIONARY
@export var gossiper_ID: int = 0
@export var npc_allowed_zone_layers: Array[int] = []

@export_group("Timer Control")
	# vars controlling waiting periods
@export var min_look_time_elapsed: float = 5.0
@export var max_look_time_elapsed: float = 10.0
@export var min_wander_wait: float = 5.0
@export var max_wander_wait: float = 10.0

signal npc_status_changed(new_status: Enums.NpcState)
signal player_listening_call(gossiper_npc: Npc, listening_status: bool)

var looking_at_entity: bool = false
var target_look_position: Vector3 = Vector3.ZERO
var has_active_target = false

var current_state = Enums.NpcState.IDLE:
	set(value):
		if current_state != value:
			current_state = value
			npc_status_changed.emit(current_state)

var player_listening = false:
	set(value):
		if player_listening != value:
			player_listening = value
			if npc_type == Enums.NpcType.GOSSIPER:
				player_listening_call.emit(self, value)

# constants
const SPEED = 3.0
const TURN_SPEED = 3.0

# initialisation
func _ready():
	# check if signal already connected - connect if not
	if !nav_agent.velocity_computed.is_connected(Callable(_on_navigation_agent_3d_velocity_computed)):
		nav_agent.velocity_computed.connect(Callable(_on_navigation_agent_3d_velocity_computed))
		
	# add self to group
	add_to_group("npcs")
	
	# change self based off type
	sprite.texture = load(ResourcePaths.npc_icon_path + Enums.NpcType.keys()[npc_type] + ".png")
	if npc_type == Enums.NpcType.WANDER_ALL || npc_type == Enums.NpcType.WANDER_ZONE:
		wander_timer.start(_generate_wander_wait())
	
	# mesh was shared between NPCs - this fixes it
	# TODO: find a better fix
	text_display.mesh = text_display.mesh.duplicate(true)
	
	if npc_type == Enums.NpcType.GOSSIPER:
		gossiper_component.gossiping_active.connect(_set_gossiping)


func _physics_process(delta: float) -> void:
	# TODO: fix this up so look should be set in startup
		# I tried to fix this one night, but had problems and I can't remember what problems lol
	if not looking_at_entity:
		_on_look_timer_timeout()
	
	if debug_mode:
		# set mesh to what the state of the NPC is
		text_display.mesh.text = Enums.NpcState.find_key(current_state)
	
	# check if active target
	if current_state == Enums.NpcState.MOVING:
		# dont query when the map has never synchronized and is empty
		if NavigationServer3D.map_get_iteration_id(nav_agent.get_navigation_map()) == 0:
			return
			
		# if finished navigation, return to IDLE state
		if nav_agent.is_navigation_finished():
			current_state = Enums.NpcState.IDLE
			has_active_target = false
			return
		
		# get next position, direction and velocity
		var next_pos: Vector3 = nav_agent.get_next_path_position()
		var direction: Vector3 = global_position.direction_to(next_pos) * SPEED
		var new_velocity: Vector3 = velocity + (direction - velocity)
		
		nav_agent.set_velocity(new_velocity)
		
		# look at direction
		_look_at_position(next_pos, delta)
		
	elif current_state == Enums.NpcState.WATCHING:
		_look_at_position(player.global_transform.origin, delta)
		
	elif current_state == Enums.NpcState.IDLE:
		_look_at_position(target_look_position, delta)
		

# runtime set self (used when npc_type == "group" given they are dynamically generated)
func _set_npc_type(type: Enums.NpcType) -> void:
	npc_type = type
	sprite.texture = load(ResourcePaths.npc_icon_path + Enums.NpcType.keys()[npc_type] + ".png")

# set desired target
func _set_movement_target(movement_target: Vector3):
	nav_agent.set_target_position(movement_target)

# if NPC requested to move (either by origin or called in wander timeout) get new target position
func _get_new_target_position():
	if Enums.NpcType.keys()[npc_type] == "GROUP":
		# get position by calling parent
		_set_movement_target(get_parent()._get_random_position_in_annulus(true))
	# most of the processing is same across both wander_all and wander_zone, so I've merged them
	elif Enums.NpcType.keys()[npc_type].contains("WANDER"):
		var world = get_world_3d().navigation_map
		var nav_layer = 1
		if Enums.NpcType.keys()[npc_type] == "WANDER_ZONE":
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
		
		# wander_all will always have a nav_layer of 1
		var random_location = NavigationServer3D.map_get_random_point(world, nav_layer, true)
		_set_movement_target(random_location)
	# tell npc to start moving next frame
	current_state = Enums.NpcState.MOVING
	has_active_target = true

func _flatten_look_y(target_position):
	target_position.y = global_position.y
	return target_position

func _get_random_entity_pos_in_area():
	var entity_position: Vector3 = Vector3.ZERO
	if attention_range.has_overlapping_bodies():
		var entities_in_range = attention_range.get_overlapping_bodies()
		entities_in_range.erase(self)
		if entities_in_range.size() > 0:
			looking_at_entity = true
			entity_position = entities_in_range[randi_range(0, entities_in_range.size() - 1)].global_transform.origin
	
	if entity_position == Vector3.ZERO:
		entity_position = get_parent().global_transform.origin
	return entity_position
	

# source: https://forum.godotengine.org/t/slowly-interpolate-look-at-function-for-my-enemy/100750
func _look_at_position(target_position: Vector3, delta: float, turn_speed: float = TURN_SPEED) -> void:
	var target_vector := target_position - global_position

	if not target_vector.length():
		return

	# calculate rotation
	var target_rotation := lerp_angle(
		global_rotation.y,
		atan2(target_vector.x, target_vector.z),
		turn_speed * delta
	)
	
	# set rotation
	global_rotation.y = target_rotation

func _generate_wander_wait():
	# maybe add calculation off suspicion/attention?
	return randf_range(min_wander_wait, max_wander_wait)

func _set_gossiping(status: bool):
	if status:
		current_state = Enums.NpcState.GOSSIPING
	else:
		current_state = Enums.NpcState.IDLE

# ---- SIGNAL FUNCTIONS ----
func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	if current_state == Enums.NpcState.MOVING:
		velocity = safe_velocity
		move_and_slide()
		
		
func _on_bangarang_range_body_entered(body: Node3D) -> void:
	if body.is_in_group("players"):
		current_state = Enums.NpcState.WATCHING

func _on_bangarang_range_body_exited(body: Node3D) -> void:
	if body.is_in_group("players"):
		current_state = Enums.NpcState.IDLE
		if has_active_target == true:
			current_state = Enums.NpcState.MOVING

func _on_attention_range_body_entered(body: Node3D) -> void:
	if body.is_in_group("players"):
		player_listening = true

func _on_attention_range_body_exited(body: Node3D) -> void:
	if body.is_in_group("players"):
		var player_found: bool = false
		var entities = attention_range.get_overlapping_bodies()
		for entity in entities:
			if entity.is_in_group("players"):
				player_found = true
				
		if not player_found:
			player_listening = false
		
# ---- TIMER FUNCTIONS ----
func _on_look_timer_timeout() -> void:
	# get new look position
	target_look_position = _get_random_entity_pos_in_area()
	# begin timer
	look_timer.start(randf_range(min_look_time_elapsed, max_look_time_elapsed))
	
func _on_wander_timer_timeout() -> void:
	# get new wander position
	_get_new_target_position()
	# begin timer
	wander_timer.start(_generate_wander_wait())
