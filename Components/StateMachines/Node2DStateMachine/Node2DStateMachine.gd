extends BaseStateMachine
class_name Node2DStateMachine

# Clients of this script will have to be at least Node2D

var current_state: Node2DState

## Optional. Use if the client is not the direct parent. If not assigned, the parent will be set as the client.
@export var client: Node2D

func initialize() -> void:
	if !client:
		client = get_parent() as Node2D
		
	for child in get_children():
		child.initialize(self, client)
		states[child.name] = child;
		
	if get_child_count() == 0:
		printerr(client.name, "::", name, "::Has no states! DISABLED")
		disable()
		return
	
	#change_state(get_child(0).name) # Set the first state node as the entry state
	

func update(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func change_state(_next_state: StringName, _enter_stat_args = null, _exit_state_args = null):
	if current_state:
		current_state.exit_state(_exit_state_args)
		current_state.is_active = false
	current_state = states[_next_state]
	if print_enter_states:
		print(client.name,"::", current_state.name, ".enter_state()")
	current_state.enter_state(_enter_stat_args)
	current_state.is_active = true
