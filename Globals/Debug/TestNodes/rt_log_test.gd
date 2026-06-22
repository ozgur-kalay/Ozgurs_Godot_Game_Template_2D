extends Node

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_select"):
		Debug.add_log("TestScene:: Testing RT log messaging")
		
