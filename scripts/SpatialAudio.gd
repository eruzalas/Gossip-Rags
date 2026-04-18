class_name SpatialAudio extends AudioStreamPlayer3D

var soundsource: Soundsource

func raycast(name, position) -> RayCast3D:
	var r = RayCast3D.new()
	r.name
	r.position
	
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

class Soundsource extends SpatialAudio: 
	
	var raycasts: Array[RayCast3D]
	var measurement_rays: Array[RayCast3D]
	var distances: Array[float]
	var distance_to_player: float
	var distance_to_player_since_last_delay_update: float
	var delay_ms:
		set(v):
			if delay_ms != v:
				delay_ms = v
				var _soundplayer_active := soundplayer_active
				var _soundplayer_standby := soundplayer_standby

				if soundplayer_active.state == soundplayer_active.ss.active:
					soundplayer_standby.delay_ms = v
					soundplayer_active.set_inactive(xfadetime)
					soundplayer_standby.set_active(xfadetime)

					soundplayer_active = _soundplayer_standby
					soundplayer_standby = _soundplayer_active
	var room_size = 0.0
	var wetness = 1.0
	var soundplayer_active: Soundplayer
	var soundplayer_standby: Soundplayer
	var _is_playing_starting: bool = false
