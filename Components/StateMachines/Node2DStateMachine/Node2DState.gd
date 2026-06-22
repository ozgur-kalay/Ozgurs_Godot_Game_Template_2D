extends BaseState
class_name Node2DState

var parent: Node2DStateMachine
var client: Node2D

func initialize(_parent: Node2DStateMachine, _client: Node2D):
	parent = _parent
	client = _client

# Virtual methods
func enter_state(_args = null) -> void:
	pass
	
func exit_state(_args = null) -> void:
	pass

func update(_delta: float) -> void:
	pass
