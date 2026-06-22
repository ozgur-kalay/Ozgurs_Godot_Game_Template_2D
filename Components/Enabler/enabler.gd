extends Node

signal enabled
signal disabled

var _enabled: bool = true

@export var client: Node

var default_process_mode: ProcessMode

func _ready() -> void:
	if !client:
		client = get_parent()
		
	default_process_mode = client.process_mode

func enable() -> void:
	_enabled = true
	client.set_deferred("process_mode", default_process_mode)
	enabled.emit()
	
func disable() -> void:
	_enabled = true
	client.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
	disabled.emit()
