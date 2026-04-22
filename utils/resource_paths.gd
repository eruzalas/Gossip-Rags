extends Node

# autoloaded (singleton) class for stating all resource paths (so to avoid magic numbers lol)

var npc_icon_path: String

func _ready() -> void:
	# full path left partially omitted so runtime can declare specific NPC sprite
	npc_icon_path = "res://assets/images/npc_sprites/npc_sprite_"
