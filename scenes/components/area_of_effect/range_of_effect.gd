extends Area3D
# TODO: REMOVE THIS - this breaks component programming pattern but for testing sake its here
@onready var test_display_text: MeshInstance3D = $"../Test Display Text"


# signal sent to observers (players) 
#   - using observers is better than the player checking its own position constantly

signal detected_player()

func _ready() -> void:
	pass # Replace with function body.


func _process(_delta: float) -> void:
	pass

# check if entered range
func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("players"):
		# emit player detected + what player it was
		emit_signal("detected_player", [true, body])
		test_display_text.visible = true

# check if left range
func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("players"):
		# emit player not detected + what player it was
		emit_signal("detected_player", [false, body])
		test_display_text.visible = false
