extends Control

@export var number_of_bars: int = 8

# targetted bar increment per dialogue segment (currently 33 for 3 part dialogue)
# improvement idea - use instantiated number to query relevant gossiper NPC with that ID and get number of dialogue segments relevant
# ^ more dynamic - ill do after changes and fixes to the main timeline
const target_bar_increment: float = 33
const bar_prefab = preload("res://scenes/ui/GUI/timeline_component/timeline_bar_prefab/timeline_bar_prefab.tscn")

func _ready() -> void:
	SignalBus.update_timeline.connect(_update_child_bar)
	
	for i in range(number_of_bars):
		var new_bar = bar_prefab.instantiate()
		new_bar.type = Enums.TimelineBarType.OVERALL
		# again see comment in const decl section - improvements can be made
		new_bar.target_per_part = target_bar_increment
		add_child(new_bar)

func _update_child_bar(bar_num: int, active: bool, segment_number: int, leeway_value: float):
	get_children()[bar_num - 1]._update_connection(active, segment_number, target_bar_increment / leeway_value)

func _process(delta: float) -> void:
	pass
