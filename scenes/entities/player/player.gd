extends CharacterBody3D
@onready var timer: Timer = $Timer
@onready var temp_text_display_status: MeshInstance3D = $"Temp Text Display Status"

const SPEED = 10.0
const JUMP_VELOCITY = 10

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func _on_detected(args):
	var is_detected = args[0]
	var player_detected = args[1]
	# TODO: chuck code to handle multiple players - "player_detected" is unused currently
	if is_detected:
		timer.start(5)
	else:
		timer.stop()
		temp_text_display_status.visible = false

func _on_timer_timeout() -> void:
	temp_text_display_status.visible = true
