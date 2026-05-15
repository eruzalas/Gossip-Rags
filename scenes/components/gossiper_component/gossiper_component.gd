extends Node

# external references
@onready var npc: Npc = $".."
@onready var internal_activation_timer: Timer = $"Internal Activation Timer"
@onready var gossip_collection_timer: Timer = $"Gossip Collection Timer"

# runtime vars
var gossiper_dialogue: Array
var activation_time: int
var current_dialogue_segment: Dictionary
var begin_gossip: bool = false
var player_listening: bool = false
var current_increment_value: float = 0
var current_dialogue_id: int = 0

var all_gossiping_segments: Array
var current_gossiping_segment: Dictionary
var current_segment: int = 0

# consts
const SECONDS_PER_CHAR: float = 0.07
const LEEWAY_MULTIPLIER: float = 0.8

# signals
signal gossiping_active(status: bool)
signal current_gossip(gossip: Dictionary)

func _ready() -> void:
	# if NPC is of type GOSSIPER then attach and set up component
	# probs a better way to do this dynamically in NPC but anyways
	if npc.npc_type == Enums.NpcType.GOSSIPER && npc.gossiper_ID != 0:
		# get gossiper-specific dialogue (certain gossipers get different areas)
		all_gossiping_segments = DialogueProcessor._get_all_gossiper_dialogue(npc.gossiper_ID)
		current_gossiping_segment = all_gossiping_segments[current_segment]
		# set values from dict
		activation_time = current_gossiping_segment["trigger_time"]
		gossiper_dialogue = current_gossiping_segment["dialogue"]
		current_dialogue_segment = gossiper_dialogue[0]
		internal_activation_timer.start(activation_time)
		
		# signal connection
		SignalBus.player_listening_call.connect(_collect_gossip)

func _process(_delta: float) -> void:
	# if player listening then increment to timeline
	if player_listening:
		current_increment_value += _get_increment_to_timeline()
		# THERES A FUCKIGN ROUNDING ERROR IN GODOTS CODE WHIHC PREVENTS STEPS LOWER THAN 0.5
		# FROM BEING CALCULATED SO I HAVE TO DO STUPID SHIT LIKE THIS
		if current_increment_value > 1:
			SignalBus.incremented_timeline.emit(npc.gossiper_ID - 1, current_increment_value)
			current_increment_value = 0
	
# this is connected to a signal emitted from NPC
# since signalbus is used, needs to check against itself before starting collection timer
func _collect_gossip(passed_npc: Npc, listening_status: bool):
	if passed_npc.gossiper_ID == npc.gossiper_ID:
		if listening_status == true:
			gossip_collection_timer.start(_get_total_leeway_seconds())
		else:
			gossip_collection_timer.stop()
		player_listening = listening_status

# get leeway calculations
# its just 80% of total dialogue time
func _get_total_leeway_seconds() -> float:
	var total_seconds = 0
	for gossip in gossiper_dialogue:
		total_seconds += _get_dialogue_seconds(gossip["dialogue"])
		
	var required_seconds = total_seconds * LEEWAY_MULTIPLIER
	return required_seconds

# get increment to timeline
# funny 100 magic number needs to be replaced with a request to timeline to get max-val
func _get_increment_to_timeline() -> float:
	var required_seconds = _get_total_leeway_seconds()
	return required_seconds / 100

# begin gossiping!!!!
func _on_internal_activation_timer_timeout() -> void:
	# the timeout runs both to start the dialogue and to increment the dialogue
	if begin_gossip == false:
		begin_gossip = true
		gossiping_active.emit(true)
	else:
		current_dialogue_id += 1
		
	# make sure gossip exists
	var gossip_exists = false
	for gossip in gossiper_dialogue:
		if gossip["ID"] == (current_dialogue_id):
			gossip_exists = true
	
	# if yes it exists, begin yapping
	if gossip_exists:
		current_dialogue_segment = gossiper_dialogue[current_dialogue_id]
		var new_timeout = _get_dialogue_seconds(current_dialogue_segment["dialogue"])
		#print(new_timeout)
		
		current_gossip.emit(current_dialogue_segment)
		
		internal_activation_timer.start(new_timeout)
	else:
		gossiping_active.emit(false)
	
# get dialogue seconds
func _get_dialogue_seconds(dialogue: String) -> float:
	return dialogue.length() * SECONDS_PER_CHAR

# on collection timeout, player cant listen so end it
func _on_gossip_collection_timer_timeout() -> void:
	player_listening = false
