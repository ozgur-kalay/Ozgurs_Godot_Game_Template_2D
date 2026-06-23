extends Node



# Adpot as required
@export var signal_clients: Dictionary[Node, StringName]


func set_signals() -> void:
	for _signal_client in signal_clients:
		var _signal: Signal = _signal_client.get(signal_clients[_signal_client])
		_signal.connect(_on_clients_signal)

func _on_clients_signal(...args) -> void:
	pass
