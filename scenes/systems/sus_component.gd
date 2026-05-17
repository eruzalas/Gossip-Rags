extends Node3D

#Default suspicion level at 0
@onready var suspicion: float = 0.00 
@onready var sus_manager: Node = get_tree().current_scene.get_node("SusManager") #Dynamically get SusManager from root tree

func _ready():
	sus_manager.change_total_sus.connect(_on_sus_change)
	
#Connect to signal 
func _on_sus_change(entity, sus_amount) -> void:
	if(entity == self.name):
		suspicion = sus_amount
		print(self.name + "'s total suspicion is " + str(suspicion)) #Checking entity sus in terminal
	
