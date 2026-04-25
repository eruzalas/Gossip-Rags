extends Node
@onready var dialogue_renderer: Sprite3D = $"../.."
@onready var dialogue_timer: Timer = $"../DialogueTimer"

# handles_gossip = whether this component should return progression gossip or generic NPC dialogue
@export var handles_gossip: bool = false
# debug_mode = prints all processing lines for traceability (also incl the temp tests I have added to demo functionality)
@export var debug_mode: bool = true

var status: Enums.NpcState = Enums.NpcState.IDLE

var current_dialogue
var dialogue_timeout = 5
var max_width_dialogue_box = 400
var bubble

var dialogue_bubble_prefab = preload("res://scenes/components/dialogue_component/dialogue_bubble.tscn")

func _ready() -> void:
	randomize()
	
	dialogue_renderer.get_parent().npc_status_changed.connect(_set_status)
	dialogue_timer.start(dialogue_timeout)
	
	bubble = dialogue_bubble_prefab.instantiate()
	add_child(bubble)
		
	if debug_mode:
		print("DEBUG MODE ACTIVE")


func _set_status(new_status: Enums.NpcState) -> void:
	status = new_status

func _process(delta: float) -> void:
	pass

func _update_dialogue_text_box(dialogue_dict:Dictionary) -> void:
	bubble.rich_text_label.text = current_dialogue["dialogue"]


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
	
	_update_dialogue_text_box(current_dialogue)
	
	dialogue_timer.start(dialogue_timeout)
