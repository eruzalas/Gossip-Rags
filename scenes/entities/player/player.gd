class_name Player

extends CharacterBody3D
@onready var timer: Timer = $Timer
@onready var temp_text_display_status: MeshInstance3D = $"Temp Text Display Status"

const SPEED = 10.0
const JUMP_VELOCITY = 10

var is_detected: bool = false
var is_slipping: bool = false

func _physics_process(delta: float) -> void:
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("p1_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("p1_left", "p1_right", "p1_up", "p1_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
	if is_slipping:
		velocity.x = lerp(velocity.x, direction.x * SPEED, 0.2)
		velocity.z = lerp(velocity.z, direction.z * SPEED, 0.2)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

func _on_detected():
	if is_detected:
		timer.start(5)
	else:
		timer.stop()
		temp_text_display_status.visible = false

func _on_timer_timeout() -> void:
	temp_text_display_status.visible = true
	
func set_slippery(state: bool):
	is_slipping = state
	
