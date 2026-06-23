@tool
extends Node
class_name FileSaveComponent

signal save_success
signal save_failed

signal load_success
signal load_failed

@export var enebled: bool = true

## OPTIONAL: If left empty then "ownername.name.bin" is used as the file name. Example Main.Player.bin. DO NOT ADD FILE EXTENSION.
@export var custom_file_name: String :
	get: return custom_file_name
	set(val):
		custom_file_name = val
		file_name = custom_file_name
		
var file_name: String

@export var encryption_key: String = "my_secret_key"
## Calls load when clients ready signal is emitted. Intended to be used at the start of the application
@export var load_on_client_ready: bool = true

## Clients properties to be saved and loaded
@export var properties: Array[StringName]

@export var debug_print_messages: bool

@export_group("Save and Load on Signals")
## Save will be called on these signals
@export var save_signals: Dictionary[Node, StringName]
## Load will be called on these signals
@export var load_signals: Dictionary[Node, StringName]

var client: Node
var dir_path: String
var file_path: String
var print_header: String

func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	if !enebled:
		return
	
	client = get_parent()
	print_header = client.name + ":" + name + ":"
	
	_set_paths()
	_create_dir_and_file()
	_connect_signals()

func _set_paths() -> void:
	if file_name.is_empty():
		file_name = owner.name + "." + client.name

	#dir_path = "res://SavedData"
	dir_path = "user://SavedData"
	
	file_path = dir_path + "/" + file_name + ".bin"
	_log_message(false, "file_path = " + file_path)

func _create_dir_and_file() -> void:
	if DirAccess.open(dir_path) == null:
		_log_message(true, "Dir does not exist, creating dir at:", dir_path)
		DirAccess.make_dir_absolute(dir_path)
		
func _connect_signals() -> void:
	# On client ready
	if load_on_client_ready:
		client.ready.connect(_client_ready)
	
	# Save
	for _signal_client in save_signals:
		if save_signals[_signal_client]:
			var _signal: Signal = _signal_client.get(save_signals[_signal_client])
			_signal.connect(_save_on_signal)
		else:
			_log_message(true, ": no value given:", "{ ", _signal_client, ":", "NO SIGNAL ASSIGNED", " }")
	# Load
	for _signal_client in load_signals:
		if load_signals[_signal_client]:
			var _signal: Signal = _signal_client.get(load_signals[_signal_client])
			_signal.connect(_load_on_signal)
		else:
			_log_message(true, ": no value given:", "{ ", _signal_client, ":", "NO SIGNAL ASSIGNED", " }")


func _client_ready(..._args) -> void:
	_log_message(false, ": client ready")
	load_data()

func _save_on_signal(..._args) -> void:
	save_data()

func _load_on_signal(..._args) -> void:
	load_data()

func save_data() -> void:
	if !enebled:
		return
		
	var file: FileAccess = FileAccess.open(file_path, FileAccess.WRITE)
	
	if file == null:
		if OS.is_debug_build():
			_log_message(true,"SAVE: File NOT open. FILE: ", file_path)
			save_failed.emit()
		return
		
	var _data: Dictionary = {}
	for _property_name in properties:
		var _property: Variant = client.get(_property_name)
		_data[_property_name] = _property
	
	var _buffer: PackedByteArray = xor_buffer(var_to_bytes(_data), encryption_key.to_utf8_buffer())
	file.store_32(_buffer.size())
	file.store_buffer(_buffer)
	file.close()
	
	_log_message(false, "save complete")
	save_success.emit()

func load_data() -> void:
	if !enebled:
		return
		
	var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	
	if file == null:
		if OS.is_debug_build():
			_log_message(true, "LOAD: File NOT open. FILE: ", file_path)
			load_failed.emit()
		return
		
	var _data_len: int = file.get_32()
	var _buffer: PackedByteArray = file.get_buffer(_data_len)
	
	var _data: Dictionary = bytes_to_var(xor_buffer(_buffer, encryption_key.to_utf8_buffer()))
	
	for _property_name in _data:
		client.set(_property_name, _data[_property_name])

	file.close()
	_log_message(false, "load complete")
	load_success.emit()
	
func xor_buffer(buffer: PackedByteArray, key: PackedByteArray) -> PackedByteArray:
	if key.is_empty(): return buffer
	
	var result := PackedByteArray()
	result.resize(buffer.size())

	for i in buffer.size():
		result[i] = buffer[i] ^ key[i % key.size()]

	return result

func _log_message(_error: bool, ...message) -> void:
	if !debug_print_messages:
		return
	if _error:
		printerr(print_header, message)
		return
	print(print_header, message)

func has_saved_data() -> bool:
	return FileAccess.file_exists(file_path)
	
