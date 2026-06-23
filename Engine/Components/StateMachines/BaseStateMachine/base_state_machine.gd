extends Node
class_name BaseStateMachine

# BASE CLASS FOR ALL STATE MACHINES
# Drived classes need to implenment own client type and call state.update() in the overridden update method.

enum ProcessOptions{_physics_process, _process}

@export var enabled: bool = true

## If true, delays initialization until after the owner node is ready.
## Ensures derived state machines can safely reference other nodes in the scene tree.
## _ready() still runs normally, but custom initialization occurs later.
@export var late_initialize: bool = true

@export var process_options: ProcessOptions
@export var print_enter_states: bool

## Defines which child state node will be used as the initial (entry) state.
## States are child nodes of this StateMachine, and this index maps directly to their order in the scene tree.
## Default is 0 (first child).
@export var entry_state_index: int = 0

@export_category("Remote Activation")
@export_group("Enabling")
@export var _enabling_client_and_signal: Dictionary[Node, StringName]

@export_group("Disabling")
@export var _disabling_client_and_signal: Dictionary[Node, StringName]

var initialized: bool

var states: Dictionary

func _ready() -> void:
	for _enable_client_node in _enabling_client_and_signal:
		var _signal_name: StringName = _enabling_client_and_signal[_enable_client_node]
		var _signal: Signal = _enable_client_node.get(_signal_name)
		_signal.connect(_on_enabling_client_signal)
	
	for _disable_client_node in _disabling_client_and_signal:
		var _signal_name: StringName = _disabling_client_and_signal[_disable_client_node]
		var _signal: Signal = _disable_client_node.get(_signal_name)
		_signal.connect(_on_disabling_client_signal)
	
	if late_initialize:
		await owner.ready
		initialize()
		initialized = true
	else:
		initialize()
		initialized = true
	
	if !enabled:
		return
	
	change_state(get_child(entry_state_index).name) # Set the first state node as the entry state
	

func _physics_process(delta: float) -> void:
	if !enabled:
		return
	if process_options == ProcessOptions._physics_process:
		update(delta)
		
func _process(delta: float) -> void:
	if !enabled:
		return
	if process_options == ProcessOptions._process:
		update(delta)

func enable() -> void:
	enabled = true
	process_mode = Node.PROCESS_MODE_INHERIT

func disable() -> void:
	enabled = false
	process_mode = Node.PROCESS_MODE_DISABLED

func _on_enabling_client_signal() -> void:
	enabled = true

func _on_disabling_client_signal() -> void:
	enabled = false

# Sets the entry (initial) state by index, determining which child state is activated first.
func set_entry_state(state_index: int) -> void:
	entry_state_index = state_index

# ==================== Virtual Methods ====================
# Example:
#	func update(delta: float) -> void:
		#if current_state:
			#current_state.update(delta)
func update(_delta) -> void:
	pass
	
func initialize() -> void:
	pass
	
func change_state(_next_state: StringName, _enter_args = null, _exit_args = null):
	pass
	
func change_to_previous_state(_enter_args = null, _exit_args = null) -> void:
	pass
# ==================== Override Methods ====================


# ==================== Custom Methods by Derived classes ====================
# Custom implementation
# Derived classes must implement own change_state() method.
# Example:
#
#	func change_state(next_state: StringName, enter_args = null, exit_args = null):
		#if !enabled:
			#return
		#if current_state:
			#current_state.exit_state(exit_args)
		#current_state = states[next_state]
		#current_state.enter_state(enter_args)
# ==================== Custom Methods by Derived classes ====================


# Example implementation of a derived StateMachine for a CharacterBody2D client.
# 
# Responsibilities:
# - Discovers and initializes child states (Character2DState) automatically.
# - Manages current and previous state transitions.
# - Provides a simple update loop that delegates to the active state.
#
# Behavior:
# - If no client is assigned, defaults to the parent CharacterBody2D.
# - Each child state receives references to this state machine and the client.
# - The first child node is used as the initial (entry) state.
# - Supports switching to a specific state or reverting to the previous state.
#
# Notes:
# - Requires child nodes to implement initialize(), enter_state(), exit_state(), and update().
# - Relies on BaseStateMachine lifecycle (e.g., late_initialize) for safe setup.
# ========= Full Example of a derived stateMachine Based on CharacterBody2D client. ===========
#var current_state: Character2DState
#var previous_state: Character2DState
#@export var client: CharacterBody2D
#
#func initialize() -> void:
	#if !client:
		#client = get_parent() as CharacterBody2D
	#for child in get_children():
		#child.initialize(self, client)
		#states[child.name] = child;
		#
	#if get_child_count() == 0:
		#printerr(client.name, "::", name, "::Has no states! DISABLED")
		#disable()
		#return
	#
	#change_state(get_child(0).name) # Set the first state node as the entry state
#
#func update(delta: float) -> void:
	#if current_state:
		#current_state.update(delta)
#
#func change_state(next_state: StringName, enter_args = null, exit_args = null):
	#if current_state:
		#current_state.exit_state(exit_args)
	#previous_state = current_state
	#current_state = states[next_state]
	#current_state.enter_state(enter_args)
	#if print_enter_states:
		#print(client.name, "::", current_state.name, "::enter_state()")
#
#func change_to_previous_state(enter_args = null, exit_args = null) -> void:
	#if current_state:
		#current_state.exit_state(exit_args)
	#var prev_state_hold = previous_state
	#previous_state = current_state
	#current_state = prev_state_hold
	#current_state.enter_state(enter_args)
