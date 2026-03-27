extends Node3D

# useful for signals https://forum.godotengine.org/t/need-help-understanding-custom-signals-between-objects/50928/2
const npc_prefab = preload("res://scenes/entities/npc/npc.tscn")

func _ready() -> void:
	# run randomise to ensure all rand calls return more random random randoms
	randomize()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
