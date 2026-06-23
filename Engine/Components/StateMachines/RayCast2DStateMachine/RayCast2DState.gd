extends BaseState
class_name RayCast2DState

var parent: RayCast2DStateMachine
var client: RayCast2D


func initialize(_parent: RayCast2DStateMachine, _client: RayCast2D):
	parent = _parent
	client = _client

func enter_state(_args = null) -> void:
	pass
	
func exit_state(_args = null) -> void:
	pass

func update(_delta: float) -> void:
	pass
