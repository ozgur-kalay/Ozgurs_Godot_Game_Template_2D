@tool
extends Control

@export var action_name: String

## Makes undo available vai crtl+z
@export var undo_available: bool

@export var button_initializers: Array[RemapButtonInitializer]:
	get: return button_initializers
	set(val):
		button_initializers = val
		_editor_rebuild_buttons()

@export_category("Internal (DO NOT CHANGE)")
@export_group("References")
@export var button_contianer: Container

func _editor_rebuild_buttons() -> void:
	for child in button_contianer.get_children():
		child.queue_free()
	
	for initializer in button_initializers:
		if !initializer:
			continue
		var button: RemapButton = initializer.get_button()
		button.action_name = action_name
		button_contianer.add_child(button, true)

var remap_buttons: Array[RemapButton]
var all_buttons: Array[Button]
var undo_buffer: Array[RemapButton]
var undo_p: int = 0

func _exit_tree() -> void:
	undo_buffer.clear()

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	if action_name.is_empty():
		printerr(name, ": Member 'action_name' (Editor: 'Action Name') must be set. Aborting...")
		return
	
	if button_contianer.get_child_count() == 0:
		return

	remap_buttons.append_array(button_contianer.get_children())
	
	for remap_button in remap_buttons:
		remap_button.action_name = action_name
		remap_button.remap_started.connect(_on_button_remap_started)
		remap_button.remap_finished.connect(_on_button_remap_finished)
		remap_button.current_event_changed.connect(_on_button_current_event_changed)

# ========= SIGNALS ============================================================================================================
# Remap Buttons
func _on_button_remap_started(button: RemapButton) -> void:
	_set_disabled_ALL_buttons(true)

func _on_button_remap_finished(button: RemapButton) -> void:
	
	_set_disabled_REMAP_buttons(false)

func _on_button_current_event_changed(button: RemapButton, event: InputEvent) -> void:
	undo_buffer.append(button)
	print(name, ": undo_buffer added")

# ===============================================================================================================================

#func _remap_actions() -> void:
	#InputMap.action_erase_events(action_name)
	#for remap_button in remap_buttons:
		#InputMap.action_add_event(action_name, remap_button.current_event)

# ========= ENABLING ============================================================================================================
func _set_disabled_ALL_buttons(disabled: bool, exclude: RemapButton = null) -> void:
	for button in all_buttons:
		if button == exclude:
			continue
		button.disabled = disabled

func _set_disabled_REMAP_buttons(disabled: bool, exclude: RemapButton = null) -> void:
	for remap_button in remap_buttons:
		if remap_button == exclude:
			continue
		remap_button.disabled = disabled
		
# ==============================================================================================================================

var undo_in_progress: bool
var ctrl_key_holding: bool
var z_key_holding: bool

# ======== Undo ==========================
func _input(event: InputEvent) -> void:
	if undo_available and !undo_buffer.is_empty():
		if event is not InputEventKey:
			return
		var key_event: InputEventKey = event as InputEventKey
		if key_event.is_pressed() and key_event.keycode == KEY_CTRL:
			ctrl_key_holding = true
		
		if key_event.is_released() and key_event.keycode == KEY_CTRL:
			ctrl_key_holding = false
			undo_in_progress = false
			
		if key_event.is_pressed() and key_event.keycode == KEY_Z:
			z_key_holding = true
			
		if key_event.is_released() and key_event.keycode == KEY_Z:
			z_key_holding = false
			undo_in_progress = false
		
		if ctrl_key_holding and z_key_holding:
			undo()

func undo() -> void:
	if undo_in_progress:
		return
	undo_in_progress = true
	var button: RemapButton = undo_buffer[-1]
	if button.is_undo_available():
		button.undo()
	undo_buffer.remove_at(undo_buffer.find(button))
	print(name, ": undo applied: undo_buffer = ", undo_buffer)

# PUBLIC API
func load_default_events() -> void:
	for button in remap_buttons:
		button.load_default_event()

# Test button functions
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if !InputMap.has_action(action_name):
		return
		
	if Input.is_action_just_pressed(action_name):
		print(name, ":", action_name, ": pressed")
