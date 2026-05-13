extends AudioStreamPlayer3D
class_name SimplifiedOccluder3D

# How much to reduce volume when occluded
@export var occlusion_db: float = -8.0;

# Low-pass filter cutoff when occluded
@export var cutoff_hz: float = 800;

# How fast to transition effects
@export var transition_speed: float = 5.0;

# Number of additional vertical rays
@export var extra_rays: int = 2  

# Height offset for extra rays
@export var vertical_offset: float = 1.0  

var target_volume = 0.0
var target_cutoff = 20000.0

var player1: Node3D;
var player2: Node3D;

var players: Array

func _ready() -> void:
	var players = get_tree().get_nodes_in_group("players");
	if (players.size() <= 0):
		print("Players not found. Are you sure they're within the group or exist in the world?");
		return;
		
	player1 = players[0];

func _process(delta):
	if (!player1):
		return;

func _get_closest_player() -> CharacterBody3D:
	var the_best_player_who_is_closest = players[0]
	for player in players:
		if global_position.distance_to(player.global_position) < global_position.distance_to(the_best_player_who_is_closest.global_position):
			the_best_player_who_is_closest = player
	return the_best_player_who_is_closest

	var space_state = get_world_3d().direct_space_state
	var origin = global_position
	var player1_pos = player1.global_position

	var rays_blocked = 0
	var total_rays = extra_rays * 2 + 1  # Middle + extra rays

	for i in range(-extra_rays, extra_rays + 1):
		var offset = Vector3(0, i * vertical_offset, 0)
		var query = PhysicsRayQueryParameters3D.create(origin + offset, player1_pos + offset)
		query.collide_with_areas = false
		var result = space_state.intersect_ray(query)

		if result and not result.collider.is_in_group("players"):
			rays_blocked += 1

	# Compute occlusion percentage
	var occlusion_factor = rays_blocked / float(total_rays)
	target_volume = lerp(0.0, occlusion_db, occlusion_factor)
	target_cutoff = lerp(20000.0, cutoff_hz, occlusion_factor)

	# Smooth transitions
	volume_db = lerp(volume_db, target_volume, delta * transition_speed)
	attenuation_filter_cutoff_hz = lerp(attenuation_filter_cutoff_hz, target_cutoff, delta * transition_speed)
