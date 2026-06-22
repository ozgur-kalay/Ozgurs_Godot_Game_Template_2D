extends Node

@export var debug_logs: DebugLogs

var debug_enabled: bool = true
@onready var menu: CanvasLayer = $Menu

func _ready() -> void:
	if !OS.is_debug_build():
		debug_enabled = false
		process_mode = Node.PROCESS_MODE_DISABLED
		menu.hide()

func add_log(message, error: bool = false) -> void:
	if !debug_enabled:
		return
	debug_logs.add_log(message, error)
