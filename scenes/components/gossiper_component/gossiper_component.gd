extends Node

@onready var npc: Npc = $".."
@onready var attention_range: Area3D = $"../Attention Range"
@onready var internal_activation_timer: Timer = $"Internal Activation Timer"
@onready var gossip_collection_timer: Timer = $"Gossip Collection Timer"

var gossiper_dialogue: Array
var activation_time: int
var current_dialogue_segment: Dictionary
var begin_gossip: bool = false
var player_listening: bool = false
var current_increment_value: float = 0
var current_dialogue_id: int = 1

const SECONDS_PER_CHAR = 0.07

signal gossiping_active(status: bool)
signal current_gossip(gossip: Dictionary)

func _ready() -> void:
	if npc.npc_type == Enums.NpcType.GOSSIPER && npc.gossiper_ID != 0:
		var gossiper_dict = DialogueProcessor._get_all_gossiper_dialogue(npc.gossiper_ID)
		activation_time = gossiper_dict["trigger_time"]
		gossiper_dialogue = gossiper_dict["dialogue"]
		current_dialogue_segment = gossiper_dialogue[0]
		internal_activation_timer.start(activation_time)
		SignalBus.player_listening_call.connect(_collect_gossip)

func _process(_delta: float) -> void:
	if player_listening:
		current_increment_value += _get_increment_to_timeline()
		if current_increment_value > 1:
			SignalBus.incremented_timeline.emit(npc.gossiper_ID - 1, current_increment_value)
			current_increment_value = 0
	
func _collect_gossip(passed_npc: Npc, listening_status: bool):
	if passed_npc.gossiper_ID == npc.gossiper_ID:
		if listening_status == true:
			gossip_collection_timer.start(_get_total_leeway_seconds())
			player_listening = true
		else:
			gossip_collection_timer.stop()
			player_listening = false

func _get_total_leeway_seconds() -> float:
	var total_seconds = 0
	for gossip in gossiper_dialogue:
		total_seconds += _get_dialogue_seconds(gossip["dialogue"])
	
	var required_seconds = total_seconds * 0.8
	return required_seconds

func _get_increment_to_timeline() -> float:
	var required_seconds = _get_total_leeway_seconds()
	return required_seconds / 100
				
func _on_internal_activation_timer_timeout() -> void:
	if begin_gossip == false:
		begin_gossip = true
		gossiping_active.emit(true)
	else:
		current_dialogue_id += 1
		
	var gossip_exists = false
	for gossip in gossiper_dialogue:
		if gossip["part"] == (current_dialogue_id):
			gossip_exists = true
	
	if gossip_exists:
		current_dialogue_segment = gossiper_dialogue[current_dialogue_id - 1]
		var new_timeout = _get_dialogue_seconds(current_dialogue_segment["dialogue"])
		print(new_timeout)
		
		current_gossip.emit(current_dialogue_segment)
		
		internal_activation_timer.start(new_timeout)
	else:
		gossiping_active.emit(false)
	

func _get_dialogue_seconds(dialogue: String) -> float:
	return dialogue.length() * SECONDS_PER_CHAR

func _on_gossip_collection_timer_timeout() -> void:
	player_listening = false
