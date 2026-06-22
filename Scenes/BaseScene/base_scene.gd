extends Node2D
class_name Scene

@export_group("Load Next Scene On Signal")
## Next scene is the next scene in the SceneManager.scene_repository that comes after this scene.
## [Node, Name of signal]
@export var signal_clients: Dictionary[Node, StringName]

@onready var debug_name: DebugName = $Debug/DebugName

func _ready() -> void:
	if !signal_clients.is_empty():
		for i in signal_clients.size():
			var _client: Node = signal_clients.keys()[i]
			var _signal_name: StringName = signal_clients[_client]
			var _signal: Signal = _client.get(_signal_name)
			_signal.connect(_on_signal_client_recieved)
			

func _on_signal_client_recieved(_args = null) -> void:
	SceneManager.change_to_next_scene()
