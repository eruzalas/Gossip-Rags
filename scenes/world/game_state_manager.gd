extends Node

# Nodes the script uses
@onready var player_1: CharacterBody3D = $"../Player1"
@onready var player_2: CharacterBody3D = $"../Player2"
@onready var attention_system: Node = %"Attention System"
@onready var suspicion_system: Node = %"Suspicion System"

# Values to keep track of for Player 1
var P_1_att_state: String = ""
var P_1_sus_state: String = ""
var P_1_att_level: float = 0
var P_1_sus_level: float = 0

# Values to keep track of for Player 2
var P_2_att_state: String = ""
var P_2_sus_state: String = ""
var P_2_att_level: float = 0
var P_2_sus_level: float = 0

#Global variables
#increases by 1 each second the player is in the gossip zone - returns to 0 once no longer collecting suspicion
var steps: int = 0
var sus: bool = false #if the player is currently in a sus zone
var yoink: bool = false #if player is trying to grab attention

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	#Game constantly needs to know player states to impact NPCs--changes game effects
	P_1_sus_state = suspicion_system._state_level(P_1_sus_level)
	P_1_att_state = attention_system._state_level(P_1_att_level)
	
	P_2_sus_state = suspicion_system._state_level(P_2_sus_level)
	P_2_att_state = attention_system._state_level(P_2_att_level)
	
	#Include flag calls here for suspicion (steps are increased as the player spends time in the gossip zone)
	
	#Include flag that sends attention value of actions here for attention
	
	
# Maths to determine the sus level of the players
func _determine_sus_level(which_player: int):
	var player_sus: float
	if(which_player == 1):
		player_sus = P_1_sus_level
		player_sus = suspicion_system._calculate_sus_general(1, player_sus, steps)
		P_1_sus_level = player_sus
	else:
		player_sus = P_2_sus_level
		player_sus = suspicion_system._calculate_sus_general(1, player_sus, steps)
		P_2_sus_level = player_sus
	
# Maths to determine the attention level of the players
func _determine_att_level(which_player: int, action: float):
	var player_att: float
	if(which_player == 1):
		player_att = P_1_att_level
		player_att = attention_system._calculate_att(1, action, player_att)
		P_1_att_level = player_att
	else:
		player_att = P_2_att_level
		player_att = attention_system._calculate_att(1, action, player_att)
		P_2_att_level = player_att
	
