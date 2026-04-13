extends Control

@onready var inv: inventory = preload("res://scenes/components/inventory/player_inventory.tres")
@onready var costume_ui: Sprite2D = $costume_display

#hold state of UI, visible true/false
var is_open = false

#for cycling through displayed item
var current_costume = 0

# Called every frame. 'delta' is the elapsed time since the previous frame
#for handling button press to open/close UI
func _process(delta):
	if (Input.is_action_just_pressed("debug_menu")):
		if (is_open):
			close()
		else:
			open()
	if (Input.is_action_just_pressed("cycle")):
		cycle_slot()
	

#make the UI hidden (closed)
func close():
	self.visible = false
	is_open = false

#make the UI visiable (open)
func open():
	self.visible = true
	is_open = true

func cycle_slot():
	current_costume += 1
	if (current_costume >= inv.size()):
		current_costume = 0
	update(inv.equipment[current_costume])

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
	update(inv.equipment[current_costume])
