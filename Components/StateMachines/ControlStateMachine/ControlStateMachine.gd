extends BaseStateMachine
class_name ControlStateMachine

var current_state: ControlState
var client: Control

func _ready() -> void:
	client = get_parent() as Control
	for child in get_children():
		child.initialize(self, client)
		states[child.name] = child

	if get_child_count() == 0:
		printerr(client.name, "::", name, "::Has no states! DISABLED")
		disable()
		return
		
	change_state(get_child(0).name) # Set the first state node as the entry state

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func change_state(next_state: StringName, enter_stat_args = null, exit_state_args = null):
	if current_state:
		current_state.exit_state(exit_state_args)
		current_state.is_active = false
	current_state = states[next_state]
	if print_enter_states:
		print(client.name,"::", current_state.name, ".enter_state()")
		
	current_state.is_active = true
	current_state.enter_state(enter_stat_args)
