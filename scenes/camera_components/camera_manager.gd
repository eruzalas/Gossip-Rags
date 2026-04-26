extends Node3D

@export var max_separation: float = 7.0
@export var split_line_thickness: float = 3.0
@export var split_line_color: Color = Color.BLACK

@onready var isMultiplayer: bool = true 	 #FOR TESTING PURPOSES, use actual signal in menu
@onready var player1: Node = $"../Player1"
@onready var player2: Node = $"../Player2"
@onready var view = $View
@onready var viewport1: Viewport = $Viewport1
@onready var viewport2: Viewport = $Viewport2
@onready var camera1: Camera3D = viewport1.get_node(^"Player1Cam")
@onready var camera2: Camera3D = viewport2.get_node(^"Player2Cam")

func _ready():

	#Add signal to change isMultiplayer between true/false
	_on_size_changed()
	view.material.set_shader_parameter("viewport1", viewport1.get_texture())
	

	if(isMultiplayer):
		_update_splitscreen()
		view.material.set_shader_parameter("viewport2", viewport2.get_texture())

	get_viewport().size_changed.connect(_on_size_changed)

	
func _process(_delta) -> void:
	
	if(isMultiplayer):
		_multiplayer_cam()
		_update_splitscreen()
		
		return
	else:
		_singleplayer_cam()
		return


func _singleplayer_cam() -> void:
	camera1.position.x = player1.position.x 
	camera1.position.y = player1.position.y + 5
	camera1.position.z = player1.position.z + 5
	

func _multiplayer_cam() -> void:

	var position_difference: Vector3 = _compute_position_difference_in_world()

	var distance: float = clamp(_compute_horizontal_length(position_difference), 0, max_separation)

	position_difference = position_difference.normalized() * distance
	
	
	
	_multi_floor_screen_resize()
	
	if(!_is_multi_floor()):
	
		camera1.position.x = player1.position.x + position_difference.x / 2.0
		camera1.position.z = (player1.position.z + position_difference.z / 2.0) + 5
	
		camera2.position.x = player2.position.x - position_difference.x / 2.0
		camera2.position.z = (player2.position.z - position_difference.z / 2.0) + 5
		
		camera1.position.y = player1.position.y + 5 
		camera2.position.y = player2.position.y + 5
	
	else: if(_is_multi_floor()):
		
		camera1.position.x = player1.position.x
		camera1.position.z = player1.position.z + 2
	
		camera2.position.x = player2.position.x
		camera2.position.z = player2.position.z + 2
		
		camera1.position.y = player1.position.y + 3
		camera2.position.y = player2.position.y + 3


func _is_multi_floor() -> bool:
	
	if(abs(player1.position.y - player2.position.y) > 1.0 ):
		return true
	
	return false

func _multi_floor_screen_resize() -> void:
	var screen_size: Vector2 = _get_screen_size() 
	
	if _is_multi_floor():
		var half_size = Vector2(screen_size.x, screen_size.y / 2.0)
		$Viewport1.size = half_size
		$Viewport2.size = half_size

	else:
		$Viewport1.size = screen_size
		$Viewport2.size = screen_size

func _get_screen_size():
	return get_viewport().get_visible_rect().size

func _is_p1_top() -> bool:
	
	if player1.position.y > player2.position.y:
		return true
		
	return false

func _update_splitscreen() -> void:
	var screen_size: Vector2 = get_viewport().get_visible_rect().size
	var player1_position: Vector2 = camera1.unproject_position(player1.position) / screen_size
	var player2_position: Vector2 = camera2.unproject_position(player2.position) / screen_size

	var position_difference: Vector3 = _compute_position_difference_in_world()
	var distance: float = _compute_horizontal_length(position_difference)
	var thickness: float = lerpf(0, split_line_thickness, (distance - max_separation) / max_separation)
	thickness = clampf(thickness, 0, split_line_thickness)


	view.material.set_shader_parameter("split_active", _get_split_state())
	view.material.set_shader_parameter("player1_position", player1_position)
	view.material.set_shader_parameter("player2_position", player2_position)
	view.material.set_shader_parameter("split_line_thickness", thickness)
	view.material.set_shader_parameter("split_line_color", split_line_color)
	view.material.set_shader_parameter("is_multi_floor", _is_multi_floor())
	view.material.set_shader_parameter("is_p1_top", _is_p1_top())


# Split screen is active if players are too far apart from each other.
# Only the horizontal components (x, z) are used for distance computation
func _get_split_state() -> bool:
	var position_difference: Vector3 = _compute_position_difference_in_world()
	var separation_distance: float = _compute_horizontal_length(position_difference)
	return separation_distance > max_separation


func _on_size_changed() -> void:
	var screen_size: Vector2 = _get_screen_size()

	$Viewport1.size = screen_size
	if(isMultiplayer):
		$Viewport2.size = screen_size

	view.material.set_shader_parameter("viewport_size", screen_size)


func _compute_position_difference_in_world() -> Vector3:
	return player2.position - player1.position


func _compute_horizontal_length(vec) -> float:
	return Vector2(vec.x, vec.z).length()
