extends Area3D

@export var connect_portal: Marker3D

func _on_body_entered(body: Node3D) -> void:
	if (body.is_in_group("players")):
		var destination = connect_portal.global_transform.origin
		body.global_transform.origin = destination
