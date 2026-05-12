class_name SpatialAudio extends AudioStreamPlayer3D

@export_category("Properties")
@export_range(1, 20_000, 0.1, "suffix:Hz") var muffle_lp_cutoff: int = 600 
@export_range(0, 5, 0.05, "or_greater", "suffix:s") var muffle_fadetime: float = 0.5 
@export_range(0, 100, 0.1, "or_greater", "suffix:m") var bass_proximity: int = 50 
@export_range(1, 100, 1, "or_greater", "suffix:m") var max_raycast_distance: int = 100
@export_flags_3d_physics var collision_mask: int = 1

@export_category("System")
@export var loop: bool = false 
@export var stop: bool = false 
@export var debug: bool = false 

@onready var player1_character: CharacterBody3D = get_node("/root/World/Player1")
@onready var raycasts_coords1: Array = [
	Vector3(0, 0, max_raycast_distance),						# N
	Vector3(max_raycast_distance, 0, max_raycast_distance),		# NW
	Vector3(max_raycast_distance, 0, 0),						# W
	Vector3(max_raycast_distance, 0, -max_raycast_distance),	# SW
	Vector3(0, 0, -max_raycast_distance),						# S
	Vector3(-max_raycast_distance, 0, -max_raycast_distance),	# SE
	Vector3(-max_raycast_distance, 0, 0),						# E
	Vector3(-max_raycast_distance, 0, max_raycast_distance),	# NE
	Vector3(0, max_raycast_distance, 0),						# U
#	Vector3(0, max_raycast_distance, max_raycast_distance),		# U 45°
#	Vector3(0, -max_raycast_distance, 0),						# D
]

@onready var player2_character: CharacterBody3D = get_node("/root/World/Player2/")
@onready var raycasts_coords2: Array = [
	Vector3(0, 0, max_raycast_distance),						# N
	Vector3(max_raycast_distance, 0, max_raycast_distance),		# NW
	Vector3(max_raycast_distance, 0, 0),						# W
	Vector3(max_raycast_distance, 0, -max_raycast_distance),	# SW
	Vector3(0, 0, -max_raycast_distance),						# S
	Vector3(-max_raycast_distance, 0, -max_raycast_distance),	# SE
	Vector3(-max_raycast_distance, 0, 0),						# E
	Vector3(-max_raycast_distance, 0, max_raycast_distance),	# NE
	Vector3(0, max_raycast_distance, 0),						# U
#	Vector3(0, max_raycast_distance, max_raycast_distance),		# U 45°
#	Vector3(0, -max_raycast_distance, 0),						# D
]

var soundsource: Soundsource

var do_update: bool = false
var tick_interval: int
var _tick_counter: int = -1 # initialize the counter with enough time for the engine to initialize
var _debug: Dictionary
var debugsphere: Node3D
var fade_tween: Tween
var lowpass_tween: Tween
var xfadetime: float = 1.000
enum fx {delay, reverb, reverb_hipass, lowpass}

func _ready():
	soundsource = Soundsource.new()
	soundsource.loop = loop
	soundsource.stop = stop
	soundsource.debug = debug
	soundsource.collision_mask = collision_mask
	
	soundsource.name = name
	soundsource.stream = stream
	soundsource.volume_db = volume_db
	soundsource.soundsource = soundsource

	add_child(soundsource)




func raycast(name, position) -> RayCast3D:
	var r = RayCast3D.new()
	r.name = name
	r.position = position
	r.collision_mask = collision_mask
	r.enabled = false
	return r

func SFX_play():
	soundsource.SFX_play()

func SFX_stop():
	soundsource.SFX_stop()

func SFX_stream(sound: AudioStream):
	soundsource.SFX_stream(sound)

func create_raycast(name_p, target_position) -> RayCast3D:
	var r = RayCast3D.new()
	r.name = name_p
	r.target_position = target_position
	r.collision_mask = collision_mask
	r.enabled = false
	return r

func create_raycast_sector(start_angle: int = 0, width_factor: float = 1.5, bearing_raycount: int = 20, heading_count: int = 7) -> Array[RayCast3D]:
	var rays: Array[RayCast3D] = []
	var i = 0
	for heading: float in range(0, heading_count, 1): # 0: ground, 7: above
		heading = heading/PI
		for bearing: float in range((bearing_raycount/2.0 * -1), (bearing_raycount/2.0)): # -7: right, 7: left
			bearing = bearing / bearing_raycount * width_factor
			var mr = RayCast3D.new()
			mr.name = "mray" + str(i)
			add_child(mr)
			mr.target_position = Vector3(max_raycast_distance, 0, 0)
			mr.collision_mask = collision_mask
			mr.debug_shape_custom_color = Color("#ff0")
			mr.debug_shape_thickness = 1
			mr.rotation = Vector3(0, bearing, heading) + Vector3(0, deg_to_rad(-start_angle), 0)
			mr.enabled = false

			if debug:
				var dray = Debugray.new()
				dray.visibility_range_end = max_raycast_distance
				dray.visibility_range_end_margin = max_raycast_distance / 10.0
				dray.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
				mr.add_child(dray)

			rays.append(mr)
			i += 1
	return rays

class Soundsource extends SpatialAudio: 
	
	var raycasts: Array[RayCast3D]
	
	
	
	
class Soundplayer extends SpatialAudio: 
	
	var muffle_raycast: RayCast3D
	
	
	func _ready():
	
		muffle_raycast = raycast("ray for " + name, position)
		add_child(muffle_raycast)
	
	
	
class Debug extends Node3D:
	var color: Color = "00f"
	var size: float = 0.5
	var max_raycast_distance: int
	var label = Label3D
	var line1: String
	var line2: String
	var line3: String
	var line4: String
	var label_offset: Vector3
