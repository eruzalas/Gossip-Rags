extends Node

@onready var npc: Npc = $".."
@onready var attention_range: Area3D = $"../Attention Range"
@onready var timeline: Control = $"../../GUI/Timeline"
@onready var in_game_clock: Timer = %"InGame Clock"
@onready var internal_activation_timer: Timer = $"Internal Activation Timer"
@onready var dialogue_renderer: Sprite3D = $"../DialogueRenderer"

var gossiper_dialogue: Array
var activation_time: int
var current_dialogue_segment: Dictionary
var begin_gossip: bool = false

const SECONDS_PER_CHAR = 0.06

signal gossiping_active(status: bool)
signal current_gossip(gossip: Dictionary)

func _ready() -> void:
	if npc.npc_type == Enums.NpcType.GOSSIPER && npc.gossiper_ID != 0:
		var gossiper_dict = DialogueProcessor._get_all_gossiper_dialogue(npc.gossiper_ID)
		activation_time = gossiper_dict["trigger_time"]
		gossiper_dialogue = gossiper_dict["dialogue"]
		current_dialogue_segment = gossiper_dialogue[0]
		internal_activation_timer.start(activation_time)

func _process(_delta: float) -> void:
	pass
	
func _on_internal_activation_timer_timeout() -> void:
	if begin_gossip == false:
		begin_gossip = true
		gossiping_active.emit(true)
		
	var current_id = current_dialogue_segment["part"]
		
	var next_gossip_exists = false
	for gossip in gossiper_dialogue:
		if gossip["part"] == (current_id + 1):
			next_gossip_exists = true
	
	if next_gossip_exists:
		current_dialogue_segment = gossiper_dialogue[current_id]
		var new_timeout = current_dialogue_segment["dialogue"].length() * SECONDS_PER_CHAR
		print(new_timeout)
		
		current_gossip.emit(current_dialogue_segment)
		
		internal_activation_timer.start(new_timeout)
	else:
		gossiping_active.emit(false)
		print("out of dialogue")
	
