extends Node3D

@export var item: costume
var players_in_range = []
var collected = false
func _ready():
	if (!item):
		queue_free() # destroys the collectable if no costume assigned
	else:
		$placeholder_sprite.hide()
		$costume_sprite.texture = item.texture

## removes the costume from the scene and from costume_in_range for all nearby players
func remove():
	collected = true
	for i in range (players_in_range.size()):
		if (players_in_range[i]):
			players_in_range[i].costume_in_range.erase(self)
	queue_free()

func _on_interactable_area_body_exited(body: Node3D):
	if (body.has_method("player")):
		print("Item: Player no longer in range")
		body.costume_in_range.erase(self)
		players_in_range.erase(body)

#sets
func _on_interactable_area_body_entered(body: Node3D):
	if (body.has_method("player") and !collected):
		print("Item: Player in range")
		body.costume_in_range.append(self)
		players_in_range.append(body)
