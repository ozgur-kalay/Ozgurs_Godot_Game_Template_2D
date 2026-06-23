extends BaseState
class_name ControlState

var parent: ControlStateMachine
var client: Control

func initialize(_parent: ControlStateMachine, _client: Control):
	parent = _parent
	client = _client
	print_header = _client.name + ":" + name + ":"

func enter_state(_args = null) -> void:
	pass
	
func exit_state(_args = null) -> void:
	pass

func update(_delta: float) -> void:
	pass
