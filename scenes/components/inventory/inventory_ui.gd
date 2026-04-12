extends Control

@onready var inv: inventory = preload("res://scenes/components/inventory/player_inventory.tres")
@onready var costume_ui: Sprite2D = $costume_display

#hold state of UI, visible true/false
var is_open = false

# Called every frame. 'delta' is the elapsed time since the previous frame
#for handling button press to open/close UI
func _process(delta):
	if (Input.is_action_just_pressed("ui_accept")):
		if (is_open):
			close()
		else:
			open()

#make the UI hidden (closed)
func close():
	self.visible = false
	is_open = false

#make the UI visiable (open)
func open():
	self.visible = true
	is_open = true

#change the displayed costume
func update(display: costume):
	if (!display):
		costume_ui.visible = false
	else:
		costume_ui.visible = true
		costume_ui.texture = display.texture

#set default state
func _ready():
	close()
	update(inv.equipment[0])
