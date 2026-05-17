extends TextureProgressBar
@export var self_bar_number: int = 0

var is_active: bool = false
var leeway_period: float = 0
var current_segment: int = 0

const TARGET_PER_PART: float = 33

func _ready() -> void:
	SignalBus.update_timeline.connect(_check_and_set_activity)

func _process(delta: float) -> void:
	if is_active:
		value += (TARGET_PER_PART / leeway_period) * delta
		
		if value > (TARGET_PER_PART * current_segment):
			value = (TARGET_PER_PART * current_segment)


func _check_and_set_activity(bar_num: int, active: bool, segment_number: int = -1, leeway_value: float = -1):
	if self_bar_number == bar_num:
		is_active = active
		current_segment = segment_number
		leeway_period = leeway_value
