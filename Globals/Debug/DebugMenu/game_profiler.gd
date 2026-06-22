extends TabBar
class_name GameProfiler

@export var game_profile_monitors: VBoxContainer
@export var game_profiler_enable_check_box: CheckBox

var _labels: Dictionary = {}

var game_profile_monitors_default_color: Color

func _ready() -> void:
	game_profile_monitors_default_color = game_profile_monitors.modulate
	if !game_profiler_enable_check_box.pressed:
		_disable_game_profile_monitors()
		

func add_game_monitor(monitor_name: String,initial_value = "") -> void:
	if _labels.has(monitor_name):
		return

	var label := Label.new()

	label.text = (
		monitor_name
		+ ": "
		+ str(initial_value)
	)

	game_profile_monitors.add_child(label)

	_labels[monitor_name] = label

func set_game_monitor(monitor_name: String,value) -> void:
	if not _labels.has(monitor_name):
		add_game_monitor(monitor_name)

	var label: Label = _labels[monitor_name]

	label.text = (
		monitor_name
		+ ": "
		+ str(value)
	)

func _on_game_profiler_enable_check_box_toggled(toggled_on: bool) -> void:
	match toggled_on:
		true:
			_enable_game_profile_monitors()
		false:
			_disable_game_profile_monitors()

func _enable_game_profile_monitors() -> void:
	game_profile_monitors.set_deferred("process_mode", Node.PROCESS_MODE_INHERIT)
	game_profile_monitors.modulate = game_profile_monitors_default_color
	
func _disable_game_profile_monitors() -> void:
	game_profile_monitors.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
	game_profile_monitors.modulate = Color(.5, .5, .5, .8)
	
