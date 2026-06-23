extends Node
class_name DebugLogs

const DEBUG_LOG = preload("uid://6obqga8br4pm")

@export var logs_container: VBoxContainer
@export var scroll_container: ScrollContainer
@export var debug_enable_check_box: CheckBox

var logs_contianer_default_color: Color

static var game_time: float

func _ready() -> void:
	logs_contianer_default_color = logs_container.modulate
	if !debug_enable_check_box.button_pressed:
		_disable_log_container()
		

func add_log(message, error: bool = false) -> void:
	if logs_container.process_mode == Node.PROCESS_MODE_DISABLED:
		return
	await get_tree().process_frame
	await get_tree().process_frame
	var _debug_log: DebugLog = DEBUG_LOG.instantiate()
	logs_container.add_child(_debug_log)
	_debug_log.set_message(message, error)
	
	await get_tree().process_frame
	
	scroll_container.scroll_vertical = int(scroll_container.get_v_scroll_bar().max_value)


func _on_debug_enable_check_box_toggled(toggled_on: bool) -> void:
	print(name, ":", "debug_enable_check_box.toggle_mode = ", debug_enable_check_box.toggle_mode)
	match toggled_on:
		true:
			_enable_log_container()
		false:
			_disable_log_container()
			
func _enable_log_container() -> void:
	logs_container.set_deferred("process_mode", Node.PROCESS_MODE_INHERIT)
	logs_container.modulate = logs_contianer_default_color
	
func _disable_log_container() -> void:
	logs_container.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
	logs_container.modulate = Color(.5, .5, .5, .8)
