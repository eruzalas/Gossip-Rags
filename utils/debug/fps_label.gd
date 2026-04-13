extends Label

# export vars
@export var display_fps: bool = true

# display FPS and update every frame
# you can also monitor the fps and stuff in the debugger options, but I like having a display onscreen too :)
func _process(_delta: float) -> void:
	if display_fps:
		text = "FPS: " + str(Engine.get_frames_per_second())
