extends Node

#System nodes (components)
@onready var suspicion_system: Node = %"Suspicion System"
@onready var attention_system: Node = %"Attention System"

#UI components
@onready var sus_debug: Label = %"Sus Debug"
@onready var attention_debug: Label = %"Attention Debug"

#addtional variables --> Will need adjustment with costumes/players and such to demonstrate debug stats
var sus: float = 0.0
var multi: float = 1.0
var steps: int = 0 #changes per second of time spent in suspicion

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
# TODO: have debug UI update alongside the sus values
func _process(delta: float) -> void:
	pass
	
func _determine_sus():
	
	pass
