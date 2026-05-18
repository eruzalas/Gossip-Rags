extends Control

@export var number_of_bars: int = 8

# targetted bar increment per dialogue segment (currently 33 for 3 part dialogue)
# improvement idea - use instantiated number to query relevant gossiper NPC with that ID and get number of dialogue segments relevant
# ^ more dynamic - ill do after changes and fixes to the main timeline
const target_bar_increment: float = 100
const num_segments_per_bar: int = 3
const bar_prefab = preload("res://scenes/ui/GUI/timeline_component/timeline_bar_prefab/timeline_bar_prefab.tscn")

func _ready() -> void:
	SignalBus.update_timeline.connect(_update_child_bar)
	
	for i in range(number_of_bars):
		var new_bar = HBoxContainer.new()
		new_bar.custom_minimum_size.y = 20
		add_child(new_bar)
		
		for j in range(num_segments_per_bar):
			var new_segment = bar_prefab.instantiate()
			new_segment.type = Enums.TimelineBarType.SEGMENTED
			# again see comment in const decl section - improvements can be made
			new_bar.add_child(new_segment)

func _update_child_bar(bar_num: int, active: bool, segment_number: int, leeway_value: float):
	# hbox_holder is the outer segment corresponding to the npc number
	var hbox_holder = get_children()[bar_num - 1]
	
	# this requests the specific segment child to update
	hbox_holder.get_children()[segment_number - 1]._update_connection(active, segment_number, target_bar_increment / leeway_value)

func _process(delta: float) -> void:
	pass
