extends Node
# Copy paste code below to where wever you need it.

@export var signal_clients: Dictionary[Node, StringName]

func set_signals() -> void:
	for client in signal_clients:
		print(client)
