extends Node

# Nodes the script uses
@onready var player_1: CharacterBody3D = $"../Player_ONE"
@onready var player_2: CharacterBody3D = $"../Player_TWO"
@onready var attention_system: Node = %"Attention System"
@onready var suspicion_system: Node = %"Suspicion System"
@onready var player_1_sus_att: Label = %"Player1 SUS ATT"
@onready var player_2_sus_att: Label = %"Player2 SUS ATT"
@onready var attention_debug: Label = %"Attention Debug"
@onready var reset_alert: Label = %"RESET ALERT"

# Values to keep track of for Player 1
var p_1_att_state: String = ""
var p_1_sus_state: String = ""
var p_1_att_level: float = 0
var p_1_sus_level: float = 0
#may change variables later depending if I can yoink them easily from player
var p1_costume_sus_level: float = 1
var p1_costume_sus_mult: float = 1
var p1_costume_att_mult: float = 1


# Values to keep track of for Player 2
var p_2_att_state: String = ""
var p_2_sus_state: String = ""
var p_2_att_level: float = 0
var p_2_sus_level: float = 0
#may change variables later depending if I can yoink them easily from player
var p2_costume_sus_level: float = 1
var p2_costume_sus_mult: float = 1
var p2_costume_att_mult: float = 1

var temp_gui_list: Array


#Global variables
var steps: int = 0 #increases by 1 each second the player is in the gossip zone - returns to 0 once no longer collecting suspicion
var sus: bool = false #if the player is currently in a sus zone - handle via signals
var yoink: bool = false #if player is trying to grab attentionm - handle via signals

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.caused_attention.connect(_on_caused_attention)
	print("DEBUG: Manager connected to SignalBus")
	temp_gui_list = [player_1_sus_att, player_2_sus_att]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	#Game constantly needs to know player states to impact NPCs--changes game effects
	p_1_sus_state = suspicion_system._state_level(p_1_sus_level)
	p_1_att_state = attention_system._state_level(p_1_att_level)
	
	p_2_sus_state = suspicion_system._state_level(p_2_sus_level)
	p_2_att_state = attention_system._state_level(p_2_att_level)
	
	#Include flag calls here for suspicion (steps are increased as the player spends time in the gossip zone)
	
	#Include flag that sends attention value of actions here for attention
	
	
# Maths to determine the sus level of the players
func _determine_sus_level(which_player: int):
	var player_sus: float
	if(which_player == 1):
		player_sus = p_1_sus_level
		player_sus = suspicion_system._calculate_sus_general(1, player_sus, steps)
		p_1_sus_level = player_sus
	else:
		player_sus = p_2_sus_level
		player_sus = suspicion_system._calculate_sus_general(1, player_sus, steps)
		p_2_sus_level = player_sus
	
# Maths to determine the attention level of the players
func _determine_att_level(which_player: int, action: float):
	var player_att: float
	if(which_player == 1):
		player_att = p_1_att_level
		player_att = attention_system._calculate_att(1, action, player_att)
		p_1_att_level = player_att
	else:
		player_att = p_2_att_level
		player_att = attention_system._calculate_att(1, action, player_att)
		p_2_att_level = player_att
	

func _on_caused_attention(player: Node, attention_value: float):
	print("DEBUG: manager received signal ")
	
	var p_id = 1 if player == player_1 else 2 #determine ID based on which player node was passed
	_determine_att_level(p_id, attention_value) #math logic
	
	#just a check in the console so that we know its working
	print("Player ", p_id, " attention is now: ",
	p_1_att_level if p_id == 1 else p_2_att_level)
	
	temp_gui_list[p_id - 1].text = "Player" + str(p_id) + " = ATT: " + str(p_1_att_level if p_id == 1 else p_2_att_level)
	
	var average_attention = (p_1_att_level + p_2_att_level) / 2
	attention_debug.text = "Attention: " + str(average_attention)
	
	if average_attention > 40:
		reset_alert.visible = true
		var timer = Timer.new()
		timer.one_shot = true
		add_child(timer)
		timer.timeout.connect(_debug_alert_invis)
		timer.start(2)
		average_attention = 0
		p_1_att_level = 0
		p_2_att_level = 0
		
	SignalBus.global_current_attention.emit(average_attention)

func _debug_alert_invis() -> void:
	reset_alert.visible = false
