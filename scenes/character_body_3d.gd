extends CharacterBody3D


var SPEED = (15 * 1)
var move_speed = 0 #used to handle speed when running/crouching, inputs required
var JUMP_VELOCITY = (10 * 1)
var acceleration = (35 * 1)
var deceleration = (15 * 1)


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	if Input.is_action_pressed("run") and !Input.is_action_pressed("crouch"):
		move_speed = SPEED * 1.5
	elif Input.is_action_pressed("crouch") and !Input.is_action_pressed("run"):
		move_speed = SPEED * 0.75
	else :
		move_speed = SPEED

	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		
		velocity.x = move_toward(velocity.x, direction.x * move_speed, acceleration * delta)
		velocity.z = move_toward(velocity.z, direction.z * move_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration * delta)
		velocity.z = move_toward(velocity.z, 0, deceleration * delta)

	move_and_slide()
