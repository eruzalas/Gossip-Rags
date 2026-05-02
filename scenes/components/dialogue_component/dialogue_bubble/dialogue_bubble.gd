extends PanelContainer
@onready var rich_text_label: RichTextLabel = $RichTextLabel
@onready var dialogue_bubble: PanelContainer = $"."

# consts
const MAX_OPACITY: float = 1.0
const LINEAR_TRANSPARENCY_DECREASE: float = 0.5

# runtime vars
var rate_of_transparency: float = 0
var can_disappear: bool = false
var base_transparency_speed: float = 4.0
var original_position: Vector2
var typewriter_tween: Tween

# signals
signal is_transparent

func _ready() -> void:
	rate_of_transparency = MAX_OPACITY / (base_transparency_speed * 60)
	original_position = position
	
func _process(_delta: float) -> void:
	if can_disappear:
		# reduce modulate for itself and children by rate of transparency
		modulate.a -= rate_of_transparency
		# emit signal to ask for deletion if 0 transparency is hit
		if modulate.a < 0:
			emit_signal("is_transparent", self)

func _set_text(text: String, display_as_typewriter: bool = false, typewriter_duration: float = 0.0) -> void:
	rich_text_label.text = text
	if display_as_typewriter:
		rich_text_label.text = text
		rich_text_label.visible_ratio = 0.0
		typewriter_tween = create_tween()
		typewriter_tween.tween_property(rich_text_label, "visible_ratio", 1.0, typewriter_duration)
		typewriter_tween.finished.connect(_start_disappear)

func _start_disappear() -> void:
	can_disappear = true

func _set_texture(path: String):
	var texture = load(ResourcePaths.dialogue_bubble_texture_path + path)
	var new_style_box = get_theme_stylebox("panel").duplicate() as StyleBoxTexture
	new_style_box.texture = texture
	add_theme_stylebox_override("panel", new_style_box)
	#dialogue_bubble.texture = load(ResourcePaths.dialogue_bubble_texture_path + path)

func _update_transparency(index: int = 0) -> void:
	var new_speed = base_transparency_speed - (index * LINEAR_TRANSPARENCY_DECREASE)

	if new_speed < 0.0:
		new_speed = 0.0
	# update rate
	rate_of_transparency = MAX_OPACITY / (new_speed * 60)
