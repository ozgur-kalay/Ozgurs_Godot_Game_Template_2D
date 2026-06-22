@tool
extends Resource
class_name RemapButtonInitializer

signal button_initializer_event_changed(event: InputEvent)

@export var button_text: String = "Not Set":
	get: return button_text
	set(val):
		button_text = val
		if button_ref:
			button_ref.text = button_text
			
@export var event: InputEvent:
	get: return event
	set(val):
		event = val
		button_initializer_event_changed.emit(event)
		if event:
			event.changed.connect(_on_event_changed.bind(event))
		else:
			button_text = "Not Set"

var button_name: String = "RemapButton"
var button_ref: Button

func _on_event_changed(_event: InputEvent) -> void:
	button_text = RemapButton.get_event_text(_event)
	button_initializer_event_changed.emit(event)

func get_button() -> RemapButton:
	var _button: RemapButton = RemapButton.new()
	button_ref = _button
	
	_button.name = button_name
	_button.text = button_text
	_button.default_event = event
	_button.size_flags_horizontal = Control.SIZE_EXPAND
	_button.size_flags_vertical = Control.SIZE_EXPAND
	_button.custom_minimum_size = Vector2(100, 30)
	
	return _button
