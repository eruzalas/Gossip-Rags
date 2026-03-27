extends Area3D
@export var is_active: bool = false
@export var origin_ID: String = ""
@export var gen_NPC_number: int = 2
@export var max_NPC_number: int = 4
@export var base_movement_chance: float = 0.5
@export var time_elapse_minimum: int = 5

const npc_prefab = preload("res://scenes/entities/npc/npc.tscn")
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var player: CharacterBody3D = $"../Player"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	
	if is_active:
		var i = 0
		while i < gen_NPC_number:
			var new_npc = npc_prefab.instantiate()
			# https://forum.godotengine.org/t/create-node-at-random-position-in-area-3d/830/2
			var npc_position = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
			var npc_dist_from_origin = randf_range(1, collision_shape_3d.shape.radius)
			npc_position.x *= npc_dist_from_origin
			npc_position.y = 1
			npc_position.z *= npc_dist_from_origin
			add_child(new_npc)
			new_npc.get_node("Range of Effect").detected_player.connect(player._on_detected)
			new_npc.global_position = collision_shape_3d.global_position + npc_position
			i += 1
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
