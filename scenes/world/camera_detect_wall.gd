extends Area3D


func _ready() -> void:
	pass # Replace with function body.



func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("transparent_walls"):
		body._change_opacity(0.10)
	
func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("transparent_walls"):
		body._change_opacity(1.00)
