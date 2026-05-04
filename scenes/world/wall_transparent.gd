extends StaticBody3D

@onready var walls: Array[Node] = self.find_children('*', "MeshInstance3D")
@onready var wall_material: Array[Material]

var target_opacity = 1.00
var current_opacity = target_opacity

func _ready():
	for wall in walls:
		wall_material.append(wall.get_active_material(0))
	

func _process(delta):
	_change_current_opacity()
	
	for mat in wall_material:
		mat.set_shader_parameter("opacity", current_opacity)


func _change_opacity(target) -> void:
	target_opacity = target

func _change_current_opacity() -> void:
	if current_opacity > target_opacity:
		current_opacity -= 0.01
	if current_opacity < target_opacity:
		current_opacity += 0.01
	
 
