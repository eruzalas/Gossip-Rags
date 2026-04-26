extends Node

# autoloaded (singleton) class for stating all resource paths (so to avoid magic numbers lol)

var npc_icon_path: String
var npc_rand_dialogue_path: String
var dialogue_bubble_texture_path: String
var gossiper_dialogue_path: String

func _ready() -> void:
	# full path left partially omitted so runtime can declare specific NPC sprite
	npc_icon_path = "res://assets/images/npc_sprites/npc_sprite_"
	npc_rand_dialogue_path = "res://assets/dialogue/npc_rand_dialogue.json"
	dialogue_bubble_texture_path = "res://assets/dialogue/"
	gossiper_dialogue_path = "res://assets/dialogue/gossiper_dialogue.json"
