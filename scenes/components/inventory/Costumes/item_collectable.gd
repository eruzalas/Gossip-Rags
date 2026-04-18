extends Node3D

var player_in_area = false
@export var item: costume

func _ready():
	if (!item):
		queue_free() # destroys the collectable if no costume assigned
	$placeholder_sprite.hide()
	$costume_sprite.texture = item.texture
	
func _process(delta):
	pass

#sets
func _on_interactable_area_body_entered(body):
	if body.has_method("player"):
		player_in_area = true
		body.player("hi")

func _on_interactable_area_body_exited(body):
	if body.has_method("player"):
		player_in_area = false
		body.player("bye")
