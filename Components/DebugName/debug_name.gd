extends Node
class_name DebugName

var _debug_name: String

func _ready() -> void:
	if owner.owner == Node:
		_debug_name = owner.owner.find_child("DebugName")._debug_name + "::" + owner.name
	else:
		_debug_name = owner.name

func get_debug_name() -> String:
	return _debug_name
