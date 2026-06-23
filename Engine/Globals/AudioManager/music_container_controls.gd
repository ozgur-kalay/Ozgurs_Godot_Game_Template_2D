extends Node

# Using a single script for all the AudioStreamPlayer containers
# Example:
#		MenuMusicContainer (node):
#							MenuMusic1 (node)
#							MenuMusic2 (node)
#							MenuMusic3 (node)
#		MenuSoundFXContainer (node):
#							MenuSFX1 (node)
#							MenuSFX2 (node)
#							MenuSFX3 (node)
@export var audio_bus_name: StringName

## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var _has_errors: bool
	if AudioServer.get_bus_index(audio_bus_name) < 0:
		Debug.add_log(name + "AudioServer does not have bus " + "'" + audio_bus_name + "'", true)
		_has_errors = true
	
	if _has_errors:
		return
	
	for child in get_children():
		if child is AudioStreamPlayer:
			child.bus = audio_bus_name
