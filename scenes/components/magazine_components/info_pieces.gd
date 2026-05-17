extends Node2D

#variables contained in scene

#portrait
@onready var info_sprite_2d: Sprite2D = $"Info Sprite2D"
@onready var info_area_2d: Area2D = $"Info Area2D"
@onready var info_collision_shape_2d: CollisionShape2D = $"Info Area2D/Info CollisionShape2D"

#text
@onready var text_sprite_2d: Sprite2D = $"Text Sprite2D"
@onready var text_area_2d: Area2D = $"Text Area2D"
@onready var rich_text_label: RichTextLabel = $RichTextLabel
@onready var collision_shape_2d: CollisionShape2D = $"Text Area2D/CollisionShape2D"

#additional variables
@export var sprite: Texture2D
var my_group: Array
var is_draggable: bool = false
var is_in_lock: bool = false
var body_ref

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	my_group = self.get_groups()
	_setup()
	print(my_group)
	
func _setup() -> void:
	if (my_group.has("text")):
		info_sprite_2d.queue_free()
		info_area_2d.process_mode = Node.PROCESS_MODE_DISABLED
		info_collision_shape_2d.disabled = true
		text_sprite_2d.texture = sprite
	elif(my_group.has("pic")):
		text_sprite_2d.queue_free()
		text_area_2d.process_mode = Node.PROCESS_MODE_DISABLED
		rich_text_label.hide()
		collision_shape_2d.disabled = true
		info_sprite_2d.texture = sprite
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#when the cursor hovers over the info
func _on_cursor_enter():
	is_draggable = true
	
#when the cursor exits hovering over the info
func _on_mouse_exit():
	is_draggable = false
	
#when the info enters the lock area
func _on_entered_area_2d_lock(body: StaticBody2D):
	if(body.is_in_group("lock")):
		is_in_lock = true
		body.modulate = Color(Color.REBECCA_PURPLE, 1)
		body = body_ref

#when the info exits the lock area
func _on_exit_area_2d_lock(body):
	if(body.is_in_group("lock")):
		is_in_lock = false
		body.modulate = Color(Color.MEDIUM_PURPLE, 0.7)

#connections for pic mouse
func _on_info_area_2d_mouse_entered() -> void:
	pass # Replace with function body.
	

func _on_info_area_2d_mouse_exited() -> void:
	pass # Replace with function body.
	

func _on_info_area_2d_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
	

func _on_info_area_2d_body_exited(body: Node2D) -> void:
	pass # Replace with function body.

#connections for text mouse
func _on_text_area_2d_mouse_entered() -> void:
	pass # Replace with function body.
	

func _on_text_area_2d_mouse_exited() -> void:
	pass # Replace with function body.
	

func _on_text_area_2d_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
	

func _on_text_area_2d_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
