extends Node3D

@export var rat_number_7: bool = true
var children = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	children = get_children()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_check_children_for_flags()


func _check_children_for_flags():
	var flag_active: bool = false
	for child in children:
		if child.movement_opportunity_flag:
			flag_active = true
	
	if flag_active:
		var temp_children = children
		var selected_child = children[randi_range(0, children.size() - 1)]
		temp_children.erase(selected_child)
		selected_child._tell_child_to_move(temp_children)
		
		for child in children:
			child._refresh_movement_opportunity_timer()
