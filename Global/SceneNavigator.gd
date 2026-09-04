extends Node

var menu_state := BaseMenu.MenuState.MAIN_MENU

func _ready():
	SettingsManager.load_settings()
	SoundManager.apply_from_settings(SettingsManager)
	TranslationServer.set_locale(SettingsManager.get_locale_from_index(SettingsManager.language))

func change_scene_to_victory():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file("res://Scenes/UI/Victory.tscn")

func change_scene_to_defeat():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file("res://Scenes/UI/Defeat.tscn")

func next_level():
	var scene_path = "res://Scenes/Levels/Level%d.tscn" % LevelStateManager.current_level

	if LevelStateManager.current_level > LevelStateManager.max_level_reach:
		LevelStateManager.max_level_reach = LevelStateManager.current_level
	LevelStateManager.current_steps = 0
	LevelStateManager.current_time = 0.0

	var previous_level = LevelStateManager.current_level - 1

	if LocationManager.is_location_changing(previous_level):
		var loader = preload("res://Scenes/UI/TransitionScreen.tscn").instantiate()
		loader.scene_to_load = scene_path
		loader.transition_text = LocationManager.Location.keys()[LocationManager.get_location_for_level(LevelStateManager.current_level)]
		loader.location_id = int(LocationManager.get_location_for_level(LevelStateManager.current_level))
		get_tree().root.add_child(loader)
	else:
		get_tree().change_scene_to_file(scene_path)

func restart_level(level: int):
	get_tree().change_scene_to_file("res://Scenes/Levels/Level%d.tscn" % level)

func return_to_menu():
	menu_state = BaseMenu.MenuState.MAIN_MENU
	get_tree().change_scene_to_file("res://Scenes/UI/MainMenu.tscn")

func return_to_location_menu():
	menu_state = BaseMenu.MenuState.LOCATION_SELECT
	SaveManager.load_progress()
	LevelStateManager.reload_save_data()
	get_tree().change_scene_to_file("res://Scenes/UI/MainMenu.tscn")

func reset_game():
	LevelStateManager.current_level = 1
	LevelStateManager.total_time = 0.0
	LevelStateManager.total_steps = 0
	get_tree().change_scene_to_file("res://Scenes/Level1.tscn")
