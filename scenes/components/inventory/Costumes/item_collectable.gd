extends Node3D

var player_in_area = false
var player = null
@export var item: costume

func _ready():
	if (!item):
		queue_free() # destroys the collectable if no costume assigned
	else:
		$placeholder_sprite.hide()
		$costume_sprite.texture = item.texture
	
func _process(delta):
	if (player_in_area && player && Input.is_action_just_pressed("interact")):
		player.pickup(item)
		queue_free()

#sets
func _on_interactable_area_body_entered(body):
	if body.has_method("player"):
		print("Item: hello")
		player_in_area = true
		player = body

func _on_interactable_area_body_exited(body):
	if body.has_method("player"):
		print("Item: bye")
		player_in_area = false
		player = null
