extends Node3D

@onready var flag_timer: Timer = $"Flag Timer"


@export var rat_number_7: bool = true
var all_children: Array = []
var valid_children: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		if child is OriginPoint:
			all_children.append(child)
	
	_get_valid_origin_points()
	flag_timer.start(3)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _get_valid_origin_points() -> void:
	valid_children.clear()
	for child in all_children:
		if child.get_children().size() > 2:
			valid_children.append(child)
	
	
func _check_children_for_flags() -> void:
	var flag_active: bool = false
	for child in valid_children:
		if child.movement_opportunity_flag:
			flag_active = true
	
	if flag_active:
		var selected_child = valid_children[randi_range(0, valid_children.size() - 1)]
		selected_child._tell_child_to_move(all_children)
		_get_valid_origin_points()
		
		for child in get_children():
			if child is OriginPoint:
				child._refresh_movement_opportunity_timer()


func _on_flag_timer_timeout() -> void:
	_check_children_for_flags()
	flag_timer.start(5)
