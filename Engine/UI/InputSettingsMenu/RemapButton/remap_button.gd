@tool
extends Button
class_name RemapButton

@export var self_remap: bool = true
@export var self_disable_on_remap: bool = true
@export var action_name: String:
	get: return action_name
	set(val):
		action_name = val
		if InputMap.has_action(action_name):
			return
		InputMap.add_action(action_name)
		
@export var default_event: InputEvent:
	get: return default_event
	set(val):
		if action_name.is_empty():
			default_event = null
			printerr(name, ": Action Name must be set first. Aborting...")
			return
			
		default_event = val
		default_event.changed.connect(_on_default_event_changed)
		
func _on_default_event_changed() -> void:
	text = _get_event_text(default_event)

signal remap_started(button: RemapButton)
signal remap_finished(button: RemapButton)

var current_event: InputEvent
var remapping: bool

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if self_remap:
		pressed.connect(_on_self_remap_button_pressed)
	
	current_event = default_event.duplicate()
	InputMap.action_add_event(action_name, current_event)
	

func _on_self_remap_button_pressed() -> void:
	remap_started.emit(self)
	remapping = true
	text = "Awaiting..."
	if self_disable_on_remap:
		disabled = true
	
func _input(event: InputEvent) -> void:
	if !Engine.is_editor_hint():
		if event.is_pressed() and event.is_match(current_event):
			toggle_mode = true
			button_pressed = true
		elif event.is_released() and event.is_match(current_event):
			toggle_mode = false
			button_pressed = false
			
	if !remapping:
		return
		
	_remap(event)

func _remap(event: InputEvent) -> void:
	if !event.is_pressed():
		return
	if event is InputEventMouseMotion:
		return
	
	InputMap.action_erase_event(action_name, current_event)
	
	current_event = event.duplicate()
	
	InputMap.action_add_event(action_name, current_event)
	
	text = _get_event_text(current_event)
	remapping = false
	
	if self_disable_on_remap:
		disabled = false
	
	remap_finished.emit(self)

func _set_event_to_inputmap(_event: InputEvent) -> void:
	var events: Array[InputEvent] = InputMap.action_get_events(action_name)
	
	var _has_event: bool = false
	
	for event in events:
		if event == _event:
			_has_event = true
		#if event.is_match(_event):
			#_has_event = true
	
	if !_has_event:
		InputMap.action_add_event(action_name, current_event)
		

# Public api
func load_default_event() -> void:
	InputMap.action_erase_event(action_name, current_event)
	current_event = default_event.duplicate()
	text = _get_event_text(current_event)
	
	if InputMap.action_has_event(action_name, current_event):
		return
		
	_set_event_to_inputmap(current_event)
	
func get_event_as_dict() -> Dictionary:
	return _get_dict_from_event(current_event)

func set_dict_as_event(dict: Dictionary) -> void:
	if action_name.is_empty():
		printerr(name, ": Action Name must be set first. Aborting...")
		return
	
	if !InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	
	InputMap.action_erase_event(action_name, current_event)
	current_event = _get_event_from_dict(dict)
	text = _get_event_text(current_event)
	_set_event_to_inputmap(current_event)



# UTILITY FUNCTIONS ==================================================================================================================

enum EventType { NONE, KEY, MOUSE_BUTTON, MOUSE_MOTION, JOYPAD_BUTTON, JOYPAD_MOTION }

static func _get_dict_from_event(event: InputEvent) -> Dictionary:
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

static func _get_event_from_dict(dict: Dictionary) -> InputEvent:
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

static func _get_event_text(event: InputEvent) -> String:
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
		match event.button_index:
			JOY_BUTTON_A: return "A"
			JOY_BUTTON_B: return "B"
			JOY_BUTTON_X: return "X"
			JOY_BUTTON_Y: return "Y"
			JOY_BUTTON_LEFT_SHOULDER: return "LB"
			JOY_BUTTON_RIGHT_SHOULDER: return "RB"
			JOY_BUTTON_BACK: return "Back"
			JOY_BUTTON_START: return "Start"
			JOY_BUTTON_LEFT_STICK: return "L-Stick Press"
			JOY_BUTTON_RIGHT_STICK: return "R-Stick Press"
			JOY_BUTTON_DPAD_UP: return "D-Pad Up"
			JOY_BUTTON_DPAD_DOWN: return "D-Pad Down"
			JOY_BUTTON_DPAD_LEFT: return "D-Pad Left"
			JOY_BUTTON_DPAD_RIGHT: return "D-Pad Right"
			_: return "Joy " + str(event.button_index)

	if event is InputEventJoypadMotion:
		match event.axis:
			JOY_AXIS_LEFT_X: return "L-Stick Right" if event.axis_value > 0 else "L-Stick Left"
			JOY_AXIS_LEFT_Y: return "L-Stick Down" if event.axis_value > 0 else "L-Stick Up"
			JOY_AXIS_RIGHT_X: return "R-Stick Right" if event.axis_value > 0 else "R-Stick Left"
			JOY_AXIS_RIGHT_Y: return "R-Stick Down" if event.axis_value > 0 else "R-Stick Up"
			JOY_AXIS_TRIGGER_LEFT: return "L-Trigger"
			JOY_AXIS_TRIGGER_RIGHT: return "R-Trigger"
			_: return "Joy Axis " + str(event.axis)

	return event.as_text()
# ==================================================================================================================
