extends Control

var is_open = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (Input.is_action_just_pressed("ui_accept")):
		if (is_open):
			close()
		else:
			open()

func close():
	self.visible = false
	is_open = false

func open():
	self.visible = true
	is_open = true
	
func _ready():
	close()
