extends BaseState
class_name Area2DState

var parent: Area2DStateMachine
var client: Area2D

func initialize(_parent: Area2DStateMachine, _client: Area2D):
	self.parent = _parent
	self.client = _client

# ============ Virtual Methods ============
func enter_state(_args = null) -> void:
	pass
	
func exit_state(_args = null) -> void:
	pass

func update(_delta: float) -> void:
	pass
