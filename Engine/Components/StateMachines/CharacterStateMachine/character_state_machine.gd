extends BaseStateMachine
class_name Character2DStateMachine

var current_state: Character2DState
var previous_state: Character2DState
@export var client: CharacterBody2D

func initialize() -> void:
	if !client:
		client = get_parent() as CharacterBody2D
	for child in get_children():
		child.initialize(self, client)
		states[child.name] = child;
		
	if get_child_count() == 0:
		printerr(client.name, "::", name, "::Has no states! DISABLED")
		disable()
		return
	
	# Testing change_state from base class
	# change_state(get_child(0).name) # Set the first state node as the entry state

func update(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func change_state(next_state: StringName, enter_args = null, exit_args = null):
	if current_state:
		current_state.exit_state(exit_args)
	previous_state = current_state
	current_state = states[next_state]
	current_state.enter_state(enter_args)
	if print_enter_states:
		print(client.name, "::", current_state.name, "::enter_state()")

func change_to_previous_state(enter_args = null, exit_args = null) -> void:
	if current_state:
		current_state.exit_state(exit_args)
	var prev_state_hold = previous_state
	previous_state = current_state
	current_state = prev_state_hold
	current_state.enter_state(enter_args)
