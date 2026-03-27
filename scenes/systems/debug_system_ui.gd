extends Node

#System nodes (components)
@onready var suspicion_system: Node = %"Suspicion System"
@onready var attention_system: Node = %"Attention System"

#UI components
@onready var sus_debug: Label = %"Sus Debug"
@onready var attention_debug: Label = %"Attention Debug"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
