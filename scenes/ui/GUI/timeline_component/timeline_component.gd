extends Control

@export var number_of_bars: int = 8

# targetted bar increment per dialogue segment (currently 33 for 3 part dialogue)
# improvement idea - use instantiated number to query relevant gossiper NPC with that ID and get number of dialogue segments relevant
# ^ more dynamic - ill do after changes and fixes to the main timeline
const target_bar_increment: float = 33
const bar_prefab = preload("res://scenes/ui/GUI/timeline_component/timeline_bar_prefab/timeline_bar_prefab.tscn")

func _ready() -> void:
	for i in range(number_of_bars):
		var new_bar = bar_prefab.instantiate()
		# again see comment in const decl section - improvements can be made
		new_bar.target_per_part = target_bar_increment
		add_child(new_bar)
		
	print(get_children())
	print("Tell child 1 to incrmeent:")
	get_children()[0]._update_connection(true, 1, target_bar_increment / 30)

func _process(delta: float) -> void:
	pass
