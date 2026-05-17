extends Node2D

#variables contained in scene
@onready var info_sprite_2d: Sprite2D = $"Info Sprite2D"
@onready var info_area_2d: Area2D = $"Info Area2D"

#additional variables
@export var sprite: Texture2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	info_sprite_2d.texture = sprite


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
