extends ShapeCast3D

@export var target_player: CharacterBody3D
var last_wall: Array[Node3D] 
var collided_wall: Array[Node3D]

var frame_set_collisions: Array[Node3D]

func _physics_process(delta: float) -> void:
	#Essentially, if collided_object is player, then no walls in way
	#If there is a wall, it will transparent it :D

	for i in collided_wall:
		i._change_opacity(1.00)
	collided_wall.clear()
		
	target_position = to_local(target_player.global_transform.origin)
	var collision_count: Array = range(get_collision_count())
	var detected_walls: Array[Node3D] = []

	if get_collision_count() != 0:
		_emily_recursion()

	for wall in frame_set_collisions:
		wall._change_opacity(0.10)

	for wall in collided_wall:
		if wall not in detected_walls:
			wall._change_opacity(1.00)

	#print("Detected_walls: ", frame_set_collisions.size() )

	collided_wall = frame_set_collisions.duplicate()

	clear_exceptions()
	frame_set_collisions.clear()



func _emily_recursion():
	var coll_wall : Node3D = get_collider(0)
	#print(coll_wall)
	if (coll_wall != null) and (coll_wall.is_in_group("transparent_walls")) and (coll_wall not in frame_set_collisions):
		frame_set_collisions.append(coll_wall)

		add_exception(coll_wall)
		force_shapecast_update()

		if get_collision_count() != 0:
			_emily_recursion()
	return




#Old Area3D solution just in case
#func _on_body_entered(body: Node3D) -> void:
	#if body.is_in_group("transparent_walls"):
		#body._change_opacity(0.10)
	#
#func _on_body_exited(body: Node3D) -> void:
	#if body.is_in_group("transparent_walls"):
		#body._change_opacity(1.00)
