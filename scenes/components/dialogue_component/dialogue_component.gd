extends Node
@onready var dialogue_renderer: Sprite3D = $"../.."
@onready var dialogue_timer: Timer = $"../DialogueTimer"

# debug_mode = prints all processing lines for traceability (also incl the temp tests I have added to demo functionality)
@export var debug_mode: bool = true

var status: Enums.NpcState = Enums.NpcState.IDLE

var current_dialogue
var dialogue_timeout = 1
var max_width_dialogue_box = 400
var bubble

var dialogue_bubble_prefab = preload("res://scenes/components/dialogue_component/dialogue_bubble.tscn")

func _ready() -> void:
	randomize()
	
	dialogue_renderer.get_parent().npc_status_changed.connect(_set_status)
	dialogue_timer.start(dialogue_timeout)
		
	if debug_mode:
		print("DEBUG MODE ACTIVE")


func _set_status(new_status: Enums.NpcState) -> void:
	status = new_status

func _process(delta: float) -> void:
	pass

func _remove_bubble(child):
	child.queue_free()
	_update_bubble_positions()

func _add_bubble(dialogue: Dictionary) -> void:
	var bubble = dialogue_bubble_prefab.instantiate()
	#bubble.base_transparency_speed = dialogue_renderer.base_transparency_speed
	
	add_child(bubble)
	bubble._set_text(dialogue["dialogue"])
	bubble._set_texture(dialogue["bubble_icon"])
	# this will need to be changed depending on if dialogue is active due to player staring?
	# TODO: REVIEW THIS
	bubble.can_disappear = true
	# make component listen to the child transparency calls
	bubble.is_transparent.connect(_remove_bubble)
	# set initial position
	_update_bubble_positions()

func _update_bubble_positions() -> void:
	var children = get_children()
	if children.size() > 1:
		var index = 0
		for child in children:
			child._update_off_index((children.size() - 1) - index)
			index += 1
	else:
		children[0]._update_off_index()


func _on_dialogue_timer_timeout() -> void:
	# if not initialised - get random dialogue
	if current_dialogue == null:
		current_dialogue = DialogueProcessor._get_random_npc_dialogue(status)
		
	# if initialised, but next_id is not "" - get next dialogue
	elif current_dialogue["next_id"] != "":
		current_dialogue = DialogueProcessor._get_next_dialogue(current_dialogue["next_id"])
		
	# else (aka is initialised and does not have a next_id) - get random dialogue
	else:
		current_dialogue = DialogueProcessor._get_random_npc_dialogue(status)
	
	if debug_mode:
		print(current_dialogue["dialogue"])
	
	_add_bubble(current_dialogue)
	
	dialogue_timer.start(dialogue_timeout)
