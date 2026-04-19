class_name SpatialAudio extends AudioStreamPlayer3D

@export_category("Properties")
@export_range(1, 20_000, 0.1, "suffix:Hz") var muffle_lp_cutoff: int = 600 
@export_range(0, 5, 0.05, "or_greater", "suffix:s") var muffle_fadetime: float = 0.5 
@export_range(0, 100, 0.1, "or_greater", "suffix:m") var bass_proximity: int = 50 
@export_flags_3d_physics var collision_mask: int = 1

@export_category("System")
@export var loop: bool = false 
@export var stop: bool = false 
@export var debug: bool = false 

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
