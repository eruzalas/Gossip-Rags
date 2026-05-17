extends Node2D

#variables contained in scene

#portrait
@onready var info_sprite_2d: Sprite2D = $"Info Sprite2D"
@onready var info_area_2d: Area2D = $"Info Area2D"

#text
@onready var text_sprite_2d: Sprite2D = $"Text Sprite2D"
@onready var text_area_2d: Area2D = $"Text Area2D"

#additional variables
@export var sprite: Texture2D
@export var type_info: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if type_info == 0:
		info_sprite_2d.texture = sprite
	elif type_info == 1:
		text_sprite_2d.texture = sprite



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
