extends Control

## The function from audio manager to call
@export var audio_manager_callable: StringName
@export var slider: HSlider
@export var mute_check_box: CheckBox
@export var reset_button: Button

var reset_volume_db: float = 0
var mute_volume: float = -80.0
var pre_mute_volume: float

var slider_default_color: Color
var slider_mute_color : Color

var muted: bool = false

func _ready() -> void:
	var has_errors: bool
	
	if !AudioManager.has_method(audio_manager_callable):
		Debug.add_log(name + ": AudioManager does not have callable " + "'" + audio_manager_callable + "'" + ".", true)
		has_errors = true
	
	if !slider:
		Debug.add_log(name + ": No volume HSlider provided.", true)
		has_errors = true
		
	if !mute_check_box:
		Debug.add_log(name + ": No mute CheckBox provided.", true)
		has_errors = true
		
	if !reset_button:
		Debug.add_log(name + ": No reset Button provided.", true)
		has_errors = true
		
	if has_errors:
		return
	
	slider.value_changed.connect(_on_slider_value_changed)
	mute_check_box.toggled.connect(_on_mute_check_box_toggled)
	reset_button.pressed.connect(_on_reset_button_pressed)
	
	slider_default_color = slider.modulate
	slider_mute_color = Color(0.5, 0.5, 0.5, 1.0)
	
	_call_audio_manager(slider.value)
	
	if mute_check_box.button_pressed:
		_mute()

func _call_audio_manager(value: float = 0) -> void:
	AudioManager.call(audio_manager_callable, value)

func _on_slider_value_changed(value: float) -> void:
	if muted:
		return
	_call_audio_manager(value)

func _on_reset_button_pressed() -> void:
	slider.value = reset_volume_db

func _on_mute_check_box_toggled(toggled_on: bool) -> void:
	match toggled_on:
		true:
			_mute()
		false:
			_unmute()

func _mute() -> void:
	pre_mute_volume = slider.value
	slider.modulate = slider_mute_color
	_call_audio_manager(mute_volume)
	muted = true

func _unmute() -> void:
	slider.modulate = slider_default_color
	muted = false
	_call_audio_manager(slider.value)
