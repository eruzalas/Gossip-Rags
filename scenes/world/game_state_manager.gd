extends Node

# Nodes the script uses
@onready var player_1: CharacterBody3D = $"../Player1"
@onready var player_2: CharacterBody3D = $"../Player2"
@onready var attention_system: Node = %"Attention System"
@onready var suspicion_system: Node = %"Suspicion System"

# Values to keep track of for Player 1
var p_1_att_state: String = ""
var p_1_sus_state: String = ""
var p_1_att_level: float = 0
var p_1_sus_level: float = 0
var p1_costume_sus_mult: float = 1
var p1_costume_att_mult: float = 1


# Values to keep track of for Player 2
var p_2_att_state: String = ""
var p_2_sus_state: String = ""
var p_2_att_level: float = 0
var p_2_sus_level: float = 0

#Global variables
var steps: int = 0 #increases by 1 each second the player is in the gossip zone - returns to 0 once no longer collecting suspicion
var sus: bool = false #if the player is currently in a sus zone - handle via signals
var yoink: bool = false #if player is trying to grab attentionm - handle via signals

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


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
	
