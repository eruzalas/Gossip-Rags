extends TextureProgressBar

# vars to be provided on initialisation in timeline component
var target_per_part: float

# vars for updating progress
var is_active: bool = false
var frames_for_target: float = 0
var current_segment: int = 0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if is_active:
		value += frames_for_target * delta
		
		if value > (target_per_part * current_segment):
			value = (target_per_part * current_segment)

func _update_connection(active: bool, segment_number: int = 0, calc_target: float = 0):
	is_active = active
	current_segment = segment_number
	frames_for_target = calc_target
		
	# pass in (TARGET_PER_PART / leeway_period)
