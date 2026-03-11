extends Node3D

# useful for signals https://forum.godotengine.org/t/need-help-understanding-custom-signals-between-objects/50928/2
const npc_prefab = preload("res://scenes/entities/npc.tscn")

func _ready() -> void:
	# run randomise to ensure all rand calls return more random random randoms
	randomize()
	var player = $Player
	for i in range(2):
		var new_npc = npc_prefab.instantiate()
		new_npc.global_position = Vector3(randi_range(-5, 5), 2, randi_range(-10, 0))
		add_child(new_npc)
		new_npc.get_node("Range of Effect").detected_player.connect(player._on_detected)
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
