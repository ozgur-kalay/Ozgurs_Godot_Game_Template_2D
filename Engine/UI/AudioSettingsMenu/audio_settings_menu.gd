extends Control

@export var menu_music_slider: HSlider

func _ready() -> void:
	AudioManager.set_volume_menu_music(menu_music_slider.value)

func _on_music_slider_value_changed(value: float) -> void:
	AudioManager.set_volume_menu_music(value)
