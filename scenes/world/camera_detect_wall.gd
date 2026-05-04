extends ShapeCast3D

@export var target_player: CharacterBody3D
var last_wall: Array[Node3D] 
var collided_wall: Array[Node3D]

func _physics_process(delta: float) -> void:
	
	#Essentially, if collided_object is player, then no walls in way
	#If there is a wall, it will transparent it :D
	
	target_position = to_local(target_player.global_transform.origin)
	var collision_count: Array = range(get_collision_count())
	var detected_walls: Array[Node3D] = []
	
	for i in collision_count:
		var coll_wall : Node3D = get_collider(i)

		if (coll_wall != null) and (coll_wall.is_in_group("transparent_walls")) and (coll_wall not in detected_walls):
			detected_walls.append(coll_wall)
	
	for wall in detected_walls:
		wall._change_opacity(0.10)
		
	for wall in collided_wall:
		if wall not in detected_walls:
			wall._change_opacity(1.00)
		
	print("Detected_walls: ", get_collision_count() )
	collided_wall = detected_walls



#Old Area3D solution just in case
#func _on_body_entered(body: Node3D) -> void:
	#if body.is_in_group("transparent_walls"):
		#body._change_opacity(0.10)
	#
#func _on_body_exited(body: Node3D) -> void:
	#if body.is_in_group("transparent_walls"):
		#body._change_opacity(1.00)
