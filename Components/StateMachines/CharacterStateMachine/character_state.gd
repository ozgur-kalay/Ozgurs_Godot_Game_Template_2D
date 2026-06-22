extends BaseState
class_name Character2DState

var parent: Character2DStateMachine
var client: CharacterBody2D

func initialize(_parent: Character2DStateMachine, _client: CharacterBody2D):
	self.parent = _parent
	self.client = _client
	print_header = client.name + ":" + name + ":"
