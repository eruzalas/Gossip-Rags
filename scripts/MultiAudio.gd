extends Resource
class_name MultiAudio

@export var sound_effects: Dictionary[String, AudioStream]

func get_audio_stream(_tag:):
	if  sound_effects.has(_tag):
		return sound_effects[_tag]
	else:
		printerr("Tag", _tag, " not found")
