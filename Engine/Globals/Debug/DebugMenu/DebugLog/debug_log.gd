extends PanelContainer
class_name DebugLog

@onready var label: Label = $Label


func set_message(message, error: bool = false) -> void:
	var time: float = float(Time.get_ticks_msec())

	var total_seconds: float = time / 1000.0

	var hours: int = floor(total_seconds / 3600.0)
	var minutes: int = floor(fmod(total_seconds, 3600.0) / 60.0)
	var seconds: int = floor(fmod(total_seconds, 60.0))

	label.text = (
		"%02d:%02d:%02d %s"
		% [hours, minutes, seconds, message]
	)

	if error:
		label.self_modulate = Color.RED
