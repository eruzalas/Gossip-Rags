extends Node

@onready var npc: CharacterBody3D = $".."
@onready var dialogue_timer: Timer = $DialogueTimer
@onready var text_bubble_frame: NinePatchRect = $TextBubbleFrame
@onready var text_margin: MarginContainer = $TextBubbleFrame/TextMargin
@onready var dialogue_text: RichTextLabel = $TextBubbleFrame/TextMargin/DialogueText

# dialogue_file = path to file - set to the generic NPC rand dialogue as default
@export var dialogue_file: String = "res://assets/dialogue/npc_rand_dialogue.json"
# handles_gossip = whether this component should return progression gossip or generic NPC dialogue
@export var handles_gossip: bool = false
# debug_mode = prints all processing lines for traceability (also incl the temp tests I have added to demo functionality)
@export var debug_mode: bool = true

# HARDCODED STATUS - THIS SHOULD INTERFACE WITH PLAYER/NPC STATE
var status = "idle"

var current_dialogue
var dialogue_timeout = 5
var max_width_dialogue_box = 400

func _ready() -> void:
	randomize()
	
	dialogue_timer.start(dialogue_timeout)
		
	if debug_mode:
		print("DEBUG MODE ACTIVE")


func _process(delta: float) -> void:
	pass

func _update_dialogue_text_box(dialogue_dict:Dictionary) -> void:
	dialogue_text.text = current_dialogue["dialogue"]
	text_bubble_frame.size.x = dialogue_text.get_content_width()


func _on_dialogue_timer_timeout() -> void:
	# if not initialised - get random dialogue
	if current_dialogue == null:
		current_dialogue = DialogueProcessor._get_random_npc_dialogue(status)
		
	# if initialised, but next_id is not "" - get next dialogue
	elif current_dialogue["next_id"] != "":
		current_dialogue = DialogueProcessor._get_next_dialogue(status, current_dialogue["next_id"])
		
	# else (aka is initialised and does not have a next_id) - get random dialogue
	else:
		current_dialogue = DialogueProcessor._get_random_npc_dialogue(status)
	
	if debug_mode:
		print(current_dialogue["dialogue"])
	
	_update_dialogue_text_box(current_dialogue)
	
	dialogue_timer.start(dialogue_timeout)
