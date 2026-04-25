extends PanelContainer
@onready var rich_text_label: RichTextLabel = $RichTextLabel

# consts
const MAX_OPACITY: int = 1.0
const LINEAR_TRANSPARENCY_DECREASE: float = 0.5

# runtime vars
var rate_of_transparency: float = 0
var can_disappear: bool = false
var base_transparency_speed: float = 4.0
var original_position: Vector2

# signals
signal is_transparent


func _ready() -> void:
	rate_of_transparency = MAX_OPACITY / (base_transparency_speed * 60)
	original_position = position


func _process(delta: float) -> void:
	if can_disappear:
		# reduce modulate for itself and children by rate of transparency
		modulate.a -= rate_of_transparency
		# emit signal to ask for deletion if 0 transparency is hit
		if modulate.a < 0:
			emit_signal("is_transparent", self)

func _set_text(dialogue: String):
	rich_text_label.text = dialogue

# update position and transparency based off index of child
# the index which is passed in is the reverse of the child list!
func _update_off_index(index: int = 0) -> void:
	# get transparency speed
	var new_speed = base_transparency_speed - (index * LINEAR_TRANSPARENCY_DECREASE)
	if new_speed < 0.0:
		new_speed = 0.0
	# update rate
	rate_of_transparency = MAX_OPACITY / (new_speed * 60)
	# update ycoord
	position.y = original_position.y - (50 * index)
