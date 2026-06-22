extends TabBar

@export var profile_monitors: VBoxContainer
@export var system_profiler_check_box: CheckBox

var profile_monitors_default_color: Color

var _monitor_labels: Dictionary = {}


func _ready() -> void:
	profile_monitors_default_color = profile_monitors.modulate
	if !system_profiler_check_box.button_pressed:
		_disable_profile_monitors()
		
	# Timing
	_add_monitor("FPS", Performance.TIME_FPS)
	_add_monitor("Process Time", Performance.TIME_PROCESS)
	_add_monitor("Physics Time", Performance.TIME_PHYSICS_PROCESS)
	
	# Rendering / Draw
	_add_monitor("Draw Calls", Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
	_add_monitor("Objects Drawn", Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)
	_add_monitor("Primitives", Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)
	
	# Memory
	_add_monitor("Static Memory", Performance.MEMORY_STATIC)
	_add_monitor("Static Memory Max", Performance.MEMORY_STATIC_MAX)

	# Objects
	_add_monitor("Objects", Performance.OBJECT_COUNT)
	_add_monitor("Resources", Performance.OBJECT_RESOURCE_COUNT)
	_add_monitor("Nodes", Performance.OBJECT_NODE_COUNT)
	_add_monitor("Orphan Nodes", Performance.OBJECT_ORPHAN_NODE_COUNT)

	# Video Memory
	_add_monitor("Texture Memory", Performance.RENDER_TEXTURE_MEM_USED)
	_add_monitor("Buffer Memory", Performance.RENDER_BUFFER_MEM_USED)

	# 2D

func _add_monitor(label_name: String, monitor: Performance.Monitor) -> void:
	var label := Label.new()

	label.text = label_name + ": 0"

	profile_monitors.add_child(label)

	_monitor_labels[monitor] = {
		"name": label_name,
		"label": label
	}


func _process(_delta: float) -> void:
	if profile_monitors.process_mode == Node.PROCESS_MODE_DISABLED:
		return
	for monitor in _monitor_labels:
		var data: Dictionary = _monitor_labels[monitor]

		var label: Label = data["label"]

		label.text = (
			data["name"]
			+ ": "
			+ str(Performance.get_monitor(monitor))
		)


func _on_system_profiler_check_box_toggled(toggled_on: bool) -> void:
	match toggled_on:
		true:
			_enable_profile_monitors()
		false:
			_disable_profile_monitors()

func _enable_profile_monitors() -> void:
	profile_monitors.set_deferred("process_mode", Node.PROCESS_MODE_INHERIT)
	profile_monitors.modulate = profile_monitors_default_color
	
func _disable_profile_monitors() -> void:
	profile_monitors.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
	profile_monitors.modulate = Color(.5, .5, .5, .8)
