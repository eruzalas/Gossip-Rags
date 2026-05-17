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
@export var type_info: int
var my_group: Array

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
