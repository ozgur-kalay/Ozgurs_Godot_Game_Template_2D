extends Node2D

@export_group("Debug Options")
enum StartingSceneOptions{NEXT_SCENE, TARGET_SCENE, TEST_SCENE}
@export var test_scene: PackedScene
@export var starting_scene_option: StartingSceneOptions
@export var target_scene_name: StringName


@export var show_current_scene_name: bool
@export_group("Scene Repository")
@export var scene_repository: Dictionary[StringName, PackedScene]

@onready var debug_scene_name_label: Label = $CanvasLayer/Debug_Scene_Name/Debug_Scene_Name_Label

@onready var debug_name: DebugName = $DebugName

var current_scene: Scene
var current_scene_idx: int = 0

func _ready() -> void:
	match starting_scene_option:
		StartingSceneOptions.NEXT_SCENE:
			_change_scene(scene_repository.keys()[0])
		StartingSceneOptions.TARGET_SCENE:
			_change_scene(target_scene_name)
		StartingSceneOptions.TEST_SCENE:
			_change_scene_to_packed(test_scene)
	
func _change_scene(_scene_name: StringName) -> void:
	await get_tree().process_frame
	get_tree().unload_current_scene()
	
	current_scene = scene_repository[_scene_name].instantiate()
	get_tree().change_scene_to_node(current_scene)
	
	if show_current_scene_name:
		_show_scene_name()
	
	current_scene_idx = _get_scene_idx(_scene_name)
	
	
	Debug.add_log(debug_name.get_debug_name() + ": Scene Loaded = " + current_scene.name)

func _show_scene_name() -> void:
	debug_scene_name_label.text = "SceneManager: DEBUG : " + current_scene.name

func _change_scene_to_packed(pck_scene: PackedScene) -> void:
	await get_tree().process_frame
	get_tree().unload_current_scene()
	
	current_scene = pck_scene.instantiate()
	get_tree().change_scene_to_node(current_scene)
	
	if show_current_scene_name:
		_show_scene_name()
	
	current_scene_idx = _get_scene_idx(current_scene.name)
	
	Debug.add_log(debug_name.get_debug_name() + ": Scene Loaded = " + current_scene.name)

func _get_scene_idx(_scene_name: StringName) -> int:
	return scene_repository.keys().find(_scene_name)

func change_to_next_scene() -> void:
	current_scene_idx += 1
	
	if current_scene_idx >= scene_repository.size():
		Debug.add_log(debug_name.get_debug_name() + ": cannot change to next scene. End of scene list", true)
	else:
		_change_scene(scene_repository.keys()[current_scene_idx])
		
