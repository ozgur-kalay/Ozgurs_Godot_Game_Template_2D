extends Node
class_name BaseState

# Derived classes must implement the following members and methods manually, not inherited.
# var parent: "Whatever StateMachineType is"
# var client: "Whatever ClientType is"
# func initialize(_parent: "Whatever StateMachineType is", _client: "Whatever ClientType is"):
	# self.parent = _parent
	# self.client = _client
	# print_header = _client.name + ":" + name + ":"

var print_header: String
var is_active: bool = false

func enter_state(_args = null) -> void:
	pass
	
func exit_state(_args = null) -> void:
	pass

func update(_delta: float) -> void:
	pass
