extends Node

const MASTER: int = 0
const MENU_MUSIC_BUS: int = 1
const MENU_SFX_BUS: int = 2

var master_volume: float
var menu_music_volume: float
var menu_sfx_volume: float
var test_string: String = "Testing a string save"
var test_bool: bool = true
var test_value: int = 0

func _ready() -> void:
	master_volume = AudioServer.get_bus_volume_db(MASTER)
	menu_music_volume = AudioServer.get_bus_volume_db(MENU_MUSIC_BUS)
	menu_sfx_volume = AudioServer.get_bus_volume_db(MENU_SFX_BUS)

func set_volume_menu_music(volume_db: float) -> void:
	AudioServer.set_bus_volume_db(MENU_MUSIC_BUS, volume_db)
	menu_music_volume = AudioServer.get_bus_volume_db(MENU_MUSIC_BUS)

func set_volume_menu_sound_fx(volume_db: float) -> void:
	AudioServer.set_bus_volume_db(MENU_SFX_BUS, volume_db)
	menu_sfx_volume = AudioServer.get_bus_volume_db(MENU_SFX_BUS)

func _process(_delta: float) -> void:
	return
	#print(menu_music_volume)
