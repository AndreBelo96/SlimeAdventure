# Script LevelMenu
extends Control

@onready var level_container: GridContainer = $CanvasLayer/RightPanel/CenterContainer/LevelButtonContainer

var loader = preload("res://Scripts/Levels/LevelLoader.gd")
var factory = preload("res://Scripts/Levels/LevelButtonFactory.gd")



func _ready():
	loader = LevelLoader.new()
	factory = LevelButtonFactory.new()
	$CanvasLayer/RightPanel/Location.text = GameManager.Location.keys()[GameManager.location_selected]
	load_level_buttons()

func load_level_buttons():
	for child in level_container.get_children():
		child.queue_free()

	var levels_info = loader.get_level_data_for_location(GameManager.location_selected)
	var levels_range = GameManager.get_level_range_for_location(GameManager.location_selected)

	for info in levels_info:
		var relative_index = levels_range.find(loader.extract_level_number(info.path)) + 1
		var location_id = int(GameManager.location_selected)
		var display_number = "%d.%d" % [location_id, relative_index]
		
		var btn = factory.create_level_button(
			display_number,
			info.disabled,
			info.theme
		)
		btn.pressed.connect(_on_level_button_pressed.bind(info.path))
		level_container.add_child(btn)

func _on_level_button_pressed(path: String):
	var level_num = loader.extract_level_number(path)
	GameManager.current_level = level_num

	var is_first_level_of_location = level_num == GameManager.get_level_range_for_location(GameManager.location_selected)[0]

	if is_first_level_of_location:
		var location_key: String = str(GameManager.location_selected + 1)
		var how_to_play_path = "res://Scenes/UI/HowToPlay%s.tscn" % location_key

		if ResourceLoader.exists(how_to_play_path):
			get_tree().change_scene_to_file(how_to_play_path)
			return
		
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		var loader_scene = preload("res://Scenes/UI/TransitionScreen.tscn").instantiate()
		loader_scene.scene_to_load = path
		loader_scene.transition_text = GameManager.Location.keys()[GameManager.get_location_for_level(level_num)]
		loader_scene.location_id = int(GameManager.get_location_for_level(level_num))
		get_tree().root.add_child(loader_scene)
	else:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		get_tree().change_scene_to_file(path)

func is_level_disabled(label: String) -> bool:
	var level_number = loader.extract_level_number(label)
	return level_number > GameManager.max_level_reach

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/LocationSelection.tscn")
