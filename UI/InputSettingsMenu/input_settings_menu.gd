extends Control

@onready var input_fields_container: VBoxContainer = $CenterContainer/PanelContainer/MarginContainer/CenterContainer/VBoxContainer/CenterContainer/InputFieldsContainer
@onready var file_save_component: FileSaveComponent = $FileSaveComponent

var saved_data: Dictionary

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	var _buttons: Array[RemapButton] = _get_remap_buttons()
	
	for button in _buttons:
		button.remap_started.connect(_on_remap_started)
		button.remap_finished.connect(_on_remap_finished)
	
	if file_save_component.has_saved_data():
		_restore_saved_data()

func _on_remap_started(_button: RemapButton) -> void:
	var _buttons: Array[RemapButton] = _get_remap_buttons()
	for button in _buttons:
		if button != _button:
			button.disabled = true

func _on_remap_finished(_button: RemapButton)-> void:
	var _buttons: Array[RemapButton] = _get_remap_buttons()
	for button in _buttons:
		if button != _button:
			button.disabled = false

func _get_remap_buttons() -> Array[RemapButton]:
	var _buttons: Array[RemapButton]
	
	for child in input_fields_container.get_children():
		var input_field: Control = child
		for input_field_child in input_field.get_children():
			if input_field_child is RemapButton:
				var remap_button: RemapButton = input_field_child
				_buttons.append(remap_button)
	
	return _buttons
	
func _get_saved_data() -> Dictionary:
	var _data: Dictionary
	for child in input_fields_container.get_children():
		var input_field: Control = child
		for input_field_child in input_field.get_children():
			if input_field_child is Button:
				var remap_button: RemapButton = input_field_child
				_data[input_field.name + remap_button.name] = remap_button.get_event_as_dict()
	
	return _data

func _save_data() -> void:
	saved_data.clear()
	for child in input_fields_container.get_children():
		var input_field: Control = child
		for input_field_child in input_field.get_children():
			if input_field_child is Button:
				var remap_button: RemapButton = input_field_child
				saved_data[input_field.name + remap_button.name] = remap_button.get_event_as_dict()
	
	file_save_component.save_data()

func _restore_saved_data() -> void:
	file_save_component.load_data()
	for child in input_fields_container.get_children():
		var input_field: Control = child
		for input_field_child in input_field.get_children():
			if input_field_child is Button:
				var remap_button: RemapButton = input_field_child
				var _dict: Dictionary = saved_data[input_field.name + remap_button.name]
				remap_button.set_dict_as_event(_dict)

func _on_save_to_file_button_pressed() -> void:
	saved_data = _get_saved_data()
	file_save_component.save_data()

func _on_load_from_file_button_pressed() -> void:
	if !file_save_component.has_saved_data():
		return
	file_save_component.load_data()
	_restore_saved_data()

func _on_load_defaults_button_pressed() -> void:
	var _buttons: Array[RemapButton] = _get_remap_buttons()
	
	for button in _buttons:
		button.load_default_event()
	
