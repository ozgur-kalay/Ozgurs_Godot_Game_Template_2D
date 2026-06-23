extends BaseStateMachine
class_name Area2DStateMachine

var previous_state: Area2DState
var current_state: Area2DState

## The node this StateMachine controls and operates on.
## If not assigned, the direct parent (expected to be an Area2D) will be used as the client.
@export var client: Area2D

func initialize() -> void:
	if !client:
		client = get_parent() as Area2D
	for child in get_children():
		child.initialize(self, client)
		states[child.name] = child;
		
	if get_child_count() == 0:
		printerr(client.name, "::", name, "::Has no states! DISABLED")
		disable()
		return

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
