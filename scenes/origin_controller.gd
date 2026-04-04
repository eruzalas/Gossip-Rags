extends Node3D

@onready var flag_timer: Timer = $"Flag Timer"


@export var rat_number_7: bool = true
var all_children: Array = []
var valid_origin_children: Array = []

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
	valid_origin_children.clear()
	for child in all_children:
		if child.get_children().size() > 2:
			valid_origin_children.append(child)
	
func _get_valid_destination(source:OriginPoint):
	var valid_destination_children: Array = []
	for child in all_children:
		if (child.get_children().size() - 2) < child.max_NPC_number && child.group_origin_ID == source.group_origin_ID:
			valid_destination_children.append(child)
			
	if valid_destination_children.is_empty():
		return source
	
	return valid_destination_children[randi_range(0, valid_destination_children.size() - 1)]
	
	
func _check_children_for_flags() -> void:
	var flag_active: bool = false
	for child in valid_origin_children:
		if child.movement_opportunity_flag:
			flag_active = true
	
	if flag_active:
		var selected_origin = valid_origin_children[randi_range(0, valid_origin_children.size() - 1)]
		var selected_destination = _get_valid_destination(selected_origin)
		
		selected_origin._tell_child_to_move(selected_destination)
		_get_valid_origin_points()
		
		for child in get_children():
			if child is OriginPoint:
				child._refresh_movement_opportunity_timer()


func _on_flag_timer_timeout() -> void:
	_check_children_for_flags()
	flag_timer.start(5)
