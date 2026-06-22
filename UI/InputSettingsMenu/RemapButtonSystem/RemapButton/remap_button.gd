extends Button
class_name RemapButton

enum EventType { NONE, KEY, MOUSE_BUTTON, MOUSE_MOTION, JOYPAD_BUTTON, JOYPAD_MOTION }

@export var action_name: String

signal remap_started(button: RemapButton)
signal remap_finished(button: RemapButton)
signal current_event_changed(button: RemapButton, current_event: InputEvent)

var current_event: InputEvent = null

var undo_buffer: Array[InputEvent] = []
var default_event: InputEvent = null
var saved_event_data: Dictionary = {}
var remapping: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if action_name.is_empty():
		printerr(name, ": Member 'action_name' (Editor: 'Action Name') must be set. Aborting...")
	
	if !InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	
	pressed.connect(_on_button_pressed)
	
	# Senario 1: No Saved file: LOAD DEFAULT EVENT
	current_event = default_event
	saved_event_data = get_dict_from_event(default_event)
	text = get_event_text(default_event)
	
	# Senario 2: Has saved File
	if !saved_event_data.is_empty():
		_load_saved_file()
		
	InputMap.action_add_event(action_name, current_event)

func _load_saved_file() -> void:
	var file_event: InputEvent = get_event_from_dict(saved_event_data)
	current_event = file_event

	saved_event_data = get_dict_from_event(current_event)
	text = get_event_text(current_event)
	
# ========= Remapping # ============================================================================================================
func _on_button_pressed() -> void:
	remapping = true
	remap_started.emit(self)
	text = "Awaiting..."

func _input(event: InputEvent) -> void:
	if !remapping:
		return
	if !event.is_pressed():
		return
	if event is InputEventMouseMotion:
		return
		
	_remap(event)

func _remap(event: InputEvent) -> void:
	InputMap.action_erase_event(action_name, current_event)
	
	_add_to_undo_buffer(current_event)
	
	current_event = event
	
	InputMap.action_add_event(action_name, current_event)
	
	saved_event_data = get_dict_from_event(current_event)
	text = get_event_text(current_event)
	remap_finished.emit(self)
	remapping = false
	
	current_event_changed.emit(self, current_event)
	
func _add_to_undo_buffer(event: InputEvent) -> void:
	undo_buffer.append(current_event.duplicate())
# ==================================================================================================================================

# public api
func load_default_event() -> void:
	_add_to_undo_buffer(current_event)
	current_event = default_event
	saved_event_data = get_dict_from_event(default_event)
	text = get_event_text(default_event)
	
func undo() -> void:
	if undo_buffer.is_empty():
		return
	var last_idx: int = undo_buffer.size() - 1
	if last_idx < 0:
		return
	current_event = undo_buffer[last_idx].duplicate()
	
	undo_buffer.remove_at(last_idx)
	
	saved_event_data = get_dict_from_event(current_event)
	
	text = get_event_text(current_event)

func is_current_event_default_event() -> bool:
	return current_event.is_match(default_event)

func is_undo_available() -> bool:
	if undo_buffer.is_empty():
		return false
	return true

static func get_dict_from_event(event: InputEvent) -> Dictionary:
	if !event:
		return { "type": EventType.NONE }

	if event is InputEventKey:
		return { "type": EventType.KEY, "keycode": event.keycode, "physical_keycode": event.physical_keycode, "unicode": event.unicode, "location": event.location }

	if event is InputEventMouseButton:
		return { "type": EventType.MOUSE_BUTTON, "button_index": event.button_index }

	if event is InputEventMouseMotion:
		return { "type": EventType.MOUSE_MOTION, "button_mask": event.button_mask, "relative": event.relative, "velocity": event.velocity }

	if event is InputEventJoypadButton:
		return { "type": EventType.JOYPAD_BUTTON, "device": event.device, "button_index": event.button_index }

	if event is InputEventJoypadMotion:
		return { "type": EventType.JOYPAD_MOTION, "device": event.device, "axis": event.axis, "axis_value": sign(event.axis_value) }

	return { "type": EventType.NONE }

static func get_event_from_dict(dict: Dictionary) -> InputEvent:
	match dict.get("type", EventType.NONE):
		EventType.KEY:
			var e := InputEventKey.new()
			e.keycode = dict.get("keycode", 0)
			e.physical_keycode = dict.get("physical_keycode", 0)
			e.unicode = dict.get("unicode", 0)
			e.location = dict.get("location", 0)
			return e

		EventType.MOUSE_BUTTON:
			var e := InputEventMouseButton.new()
			e.button_index = dict.get("button_index", 0)
			return e

		EventType.MOUSE_MOTION:
			var e := InputEventMouseMotion.new()
			e.button_mask = dict.get("button_mask", 0)
			e.relative = dict.get("relative", Vector2.ZERO)
			e.velocity = dict.get("velocity", Vector2.ZERO)
			return e

		EventType.JOYPAD_BUTTON:
			var e := InputEventJoypadButton.new()
			e.device = dict.get("device", 0)
			e.button_index = dict.get("button_index", 0)
			return e

		EventType.JOYPAD_MOTION:
			var e := InputEventJoypadMotion.new()
			e.device = dict.get("device", 0)
			e.axis = dict.get("axis", 0)
			e.axis_value = dict.get("axis_value", 0.0)
			return e

	return null

static func get_event_text(event: InputEvent) -> String:
	if !event:
		return "Not Set"

	if event is InputEventKey:
		return event.as_text_keycode().capitalize()

	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT: return "Mouse Left"
			MOUSE_BUTTON_RIGHT: return "Mouse Right"
			MOUSE_BUTTON_MIDDLE: return "Mouse Middle"
			MOUSE_BUTTON_WHEEL_UP: return "Wheel Up"
			MOUSE_BUTTON_WHEEL_DOWN: return "Wheel Down"
			_: return "Mouse " + str(event.button_index)

	if event is InputEventJoypadButton:
		return "Joy " + str(event.button_index)

	if event is InputEventJoypadMotion:
		match event.axis:
			JOY_AXIS_LEFT_X: return "Joy Right" if event.axis_value > 0 else "Joy Left"
			JOY_AXIS_LEFT_Y: return "Joy Down" if event.axis_value > 0 else "Joy Up"
			JOY_AXIS_RIGHT_X: return "Joy Right 2" if event.axis_value > 0 else "Joy Left 2"
			JOY_AXIS_RIGHT_Y: return "Joy Down 2" if event.axis_value > 0 else "Joy Up 2"
			_: return "Joy Axis " + str(event.axis)

	return event.as_text()
