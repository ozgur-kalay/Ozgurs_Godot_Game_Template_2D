extends Node

@export var time: float = 1.0
signal test_signal

func _ready() -> void:
	await get_tree().create_timer(time).timeout
	test_signal.emit()
