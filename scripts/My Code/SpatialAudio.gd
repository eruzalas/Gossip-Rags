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
enum fx {delay, lowpass}

func _ready():
	soundsource = Soundsource.new()
	
	soundsource.loop = loop
	soundsource.stop = stop
	soundsource.debug = debug
	soundsource.max_raycast_distance = max_raycast_distance
	soundsource.collision_mask = collision_mask
	
	soundsource.name = name
	soundsource.stream = stream
	soundsource.volume_db = volume_db
	soundsource.soundsource = soundsource

	add_child(soundsource)

	if autoplay:
		stop()
		await get_tree().create_timer(0.1).timeout # reverbers aren't ready.
		soundsource.do_play()


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

	var ds = {0: "active", 1: "inactive", 2: "fading_to_active", 3: "fading_to_inactive"}
	enum ss {active, inactive, fading_to_active, fading_to_inactive}
	var with_reverb_fx: bool
	var state: ss:
		set(v):
			if state != v:
				state = v
				#if debug: debugsphere.line4 = ds[v]
				#if debug: print("%s: %s --> %s" % [name, ds[state], ds[v]])
	var distance_to_soundsource: float
	var distance_to_player: float
	var target_position: Vector3:
		set(v):
			if target_position != v:
				if state != ss.fading_to_inactive:
					target_position = v
					global_position = v
	var delay_ms: int:
		set(v):
			if abs(delay_ms - v) > 10 and (Time.get_ticks_msec() - delay_updated_at) > 1000:
				delay_ms = v
				delay_updated_at = Time.get_ticks_msec()
				if debug: debugsphere.line2 = "%s ms" % delay_ms
				if state != ss.fading_to_inactive:
					set_audioeffect(audiobus_name, fx.delay, {"delay": delay_ms})
	var delay_updated_at: int
	var room_size: float:
		set(v):
			if room_size != v:
				room_size = v
				if state != ss.fading_to_inactive:
					set_audioeffect(audiobus_name, fx.reverb, {"room_size": room_size, "wetness": wetness})
	var wetness: float:
		set(v):
			if wetness != v:
				wetness = v
				# audioeffect is already set together with room_size
	var proximity_volume: float:
		set(v):
			if abs(proximity_volume - v) > 0.1:
				proximity_volume = v
				if debug: debugsphere.line3 = "%d dB" % v
				if state == ss.active:
					set_audiobus_volume(audiobus_name, proximity_volume)
	var proximity_bass: float:
		set(v):
			if proximity_bass != v:
				proximity_bass = v
				if state != ss.fading_to_inactive:
					set_audioeffect(audiobus_name, fx.reverb_hipass, {"hipass": proximity_bass})
	var lp_cutoff: int:
		set(v):
			if abs(lp_cutoff - v) > 20:
				lp_cutoff = v
				if debug: debugsphere.line4 = "occluded" if v != 20500 else ""
				set_audioeffect(audiobus_name, fx.lowpass, {"lowpass": lp_cutoff, "fadetime": occlusion_fadetime})
	var occlusion_raycast: RayCast3D
	var audiobus_name: String
	var _fade_generation: int = 0
	var _is_valid: bool = true


	func _ready():

		if debug:
			#print("spawning soundplayer: ", name)
			debugsphere = Debugsphere.new()
			debugsphere.max_raycast_distance = max_raycast_distance
			debugsphere.name = "Debugsphere " + name
			debugsphere.line1 = "♬"
			add_child(debugsphere)
			debugsphere.visible = false

		# ensure unique name for the mixer
		audiobus_name = "%s-%s" % [name, get_instance_id()]

		# create bus and add effects to it
		create_audiobus(audiobus_name)
		add_audioeffect(audiobus_name, fx.delay)
		add_audioeffect(audiobus_name, fx.reverb)
		if with_reverb_fx == false:
			toggle_audioeffect(audiobus_name, fx.reverb, false)
		add_audioeffect(audiobus_name, fx.lowpass)

		# set initial state to inactive and mute
		state = ss.inactive
		set_audiobus_volume(audiobus_name, -80)

		# set volume according to AudioStreamPlayer3D param
		proximity_volume = volume_db

		# set my bus to this newly created bus.
		bus = audiobus_name

		# create raycast for occlusion test
		occlusion_raycast = create_raycast("occray for " + name, position)
		add_child(occlusion_raycast)

		# connect signal (used to restart playing if loop is enabled)
		finished.connect(_on_finished)


	func _on_finished():
		if loop:
			soundsource.do_play()


	func _physics_process(_delta):
		if debug:
			dump_debug()
			debugsphere.update_label()


	func _exit_tree():
		_is_valid = false

		if fade_tween:
			fade_tween.kill()
		if lowpass_tween:
			lowpass_tween.kill()

		remove_audiobus(audiobus_name)

		for c in get_children():
			remove_child(c)


	func do_play():
		#if debug: printerr(str(Time.get_ticks_msec()) + ": start playing on " + name + ", stream: " + str(stream))
		play()


	func do_stop():
		#if debug: printerr(str(Time.get_ticks_msec()) + ": stop playing on " + name + ", stream: " + str(stream))
		stop()


	func set_active(fadetime: float = 0, easing: Tween.EaseType = Tween.EASE_OUT, transition: Tween.TransitionType = Tween.TRANS_QUART):
		#if debug: print("SET ACTIVE: %s (state: %s, fadetime: %s)" % [name, ds[state], fadetime])
		if state == ss.inactive:
			if debug: debugsphere.visible = true
			update_effect_params()

			if fadetime > 0:
				# stamp this coroutine's generation before yielding.
				# If set_inactive (or another set_active) is called while we await,
				# it will increment _fade_generation, and we will bail on resume
				# instead of overwriting the new state with ss.active.
				_fade_generation += 1
				var my_generation := _fade_generation
				state = ss.fading_to_active

				if fade_tween:
					fade_tween.kill()
				fade_tween = create_tween()
				fade_tween.stop()
				fade_tween.set_ease(easing)
				fade_tween.set_trans(transition)

				set_audiobus_volume(audiobus_name, proximity_volume, fadetime, fade_tween)
				await fade_tween.finished

				# bail if we were superseded or the node is being freed.
				if _fade_generation != my_generation or not _is_valid:
					return

			else:
				set_audiobus_volume(audiobus_name, proximity_volume)

			state = ss.active


	func set_inactive(fadetime: float = 0, easing: Tween.EaseType = Tween.EASE_IN, transition: Tween.TransitionType = Tween.TRANS_QUINT):
		#if debug: print("SET INACTIVE: %s (state: %s, fadetime: %s)" % [name, ds[state], fadetime])
		if state == ss.active or state == ss.fading_to_active:

			if fadetime > 0:
				# increment generation to invalidate any concurrent set_active coroutine.
				_fade_generation += 1
				var my_generation := _fade_generation
				state = ss.fading_to_inactive

				if fade_tween:
					fade_tween.kill()
				fade_tween = create_tween()
				fade_tween.stop()
				fade_tween.set_ease(easing)
				fade_tween.set_trans(transition)

				set_audiobus_volume(audiobus_name, -80, fadetime, fade_tween)
				await fade_tween.finished

				# bail if we were superseded or the node is being freed.
				if _fade_generation != my_generation or not _is_valid:
					return

			else:
				set_audiobus_volume(audiobus_name, -80)

			state = ss.inactive
			if debug: debugsphere.visible = false


	func update_effect_params():
		# update distance vars
		distance_to_soundsource = global_position.distance_to(soundsource.global_position)
		distance_to_player = global_position.distance_to(player_character.global_position)

		# occlusion
		lp_cutoff = calculate_occlusion_lowpass()

		# only calculate reverb effects on reverbers, not soundsource soundplayers.
		# soundsource will set delay on soundsource-soundplayers.
		if with_reverb_fx:
			# calculate and set delay
			delay_ms = calculate_delay(distance_to_soundsource) + calculate_delay(distance_to_player)

			# roomsize & wetness
			room_size = soundsource.room_size
			wetness = soundsource.wetness

			# set volume. further away = louder.
			# (without tuning, in small rooms, reverb is overwhelming, but you can't hear echo far away)
			proximity_volume = calculate_proximity_volume()

			# set proximity bass
			# more bass if closer to the wall, effect begins at 50m to a wall
			# hipass = 0.2
			proximity_bass = calculate_proximity_bass()


	# turn down reverb volume by [reduction] dB when closer to the wall
	func calculate_proximity_volume():
		var proximity_reduction = 24
		var max_volume = reverb_volume_db + volume_db

		# calculate reduction based on the ratio player-to-max_raycast_distance and player-to-soundsource.
		# the closer you are to a wall, the less reverb should be heard. the further away you are, the more it should be audible.
		# the further away the soundsource is, the less reverb should be heard.
		var ratio_player_rc = min(1, distance_to_player / max_raycast_distance)
		var ratio_player_ss = min(1, distance_to_player / distance_to_soundsource)
		var prox_volume = (proximity_reduction * ratio_player_rc + proximity_reduction * ratio_player_ss) / 2 - proximity_reduction

		# add soundsource max_volume
		prox_volume = prox_volume + max_volume

		# limit maximum volume to max_volume
		prox_volume = min(prox_volume, max_volume)

		return prox_volume


	func calculate_proximity_bass():
		return snappedf(min(0.2 * distance_to_player / max(bass_proximity, 0.001), 0.2), 0.001)


	func calculate_occlusion_lowpass():
		var limited_distance_to_player = clamp(distance_to_player, 0, max_raycast_distance)
		occlusion_raycast.target_position = global_position.direction_to(player_character.global_position) * max_raycast_distance * 10

		var _cutoff = 20500
		occlusion_raycast.force_raycast_update()
		if occlusion_raycast.is_colliding():
			var collision_point = occlusion_raycast.get_collision_point()
			var ray_distance = collision_point.distance_to(global_position)
			var wall_to_player_ratio = ray_distance / max(distance_to_player, 0.001)
			if ray_distance < distance_to_player:
				_cutoff = snappedf(occlusion_lp_cutoff * wall_to_player_ratio, 0.001)

		return _cutoff

class Debugray extends MeshInstance3D:

	var immediate_mesh: ImmediateMesh
	var material: ORMMaterial3D
