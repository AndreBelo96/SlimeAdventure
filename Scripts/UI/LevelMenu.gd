# Script LevelMenu
extends BaseMenu

@onready var level_container: GridContainer = $ColorRect/MarginContainer/VBoxContainer/CenterContainer2/LevelButtonContainer
@onready var location: Label = $ColorRect/MarginContainer/VBoxContainer/CenterContainer4/Location

const ROW_SIZE := 5

var loader = preload("res://Scripts/UI/Buttons/LevelLoader.gd")
var factory = preload("res://Scripts/UI/Buttons/LevelButtonFactory.gd")

func _ready():
	loader = LevelLoader.new()
	factory = LevelButtonFactory.new()
	
	location.text = GameManager.Location.keys()[GameManager.location_selected]
	load_level_buttons()

func load_level_buttons():
	for child in level_container.get_children():
		child.queue_free()
		
	buttons.clear()
	selectors.clear()
	base_positions.clear()

	var levels_info = loader.get_level_data_for_location(GameManager.location_selected)
	var levels_range = GameManager.get_level_range_for_location(GameManager.location_selected)

	for i in range(levels_info.size()):
		var info = levels_info[i]
		var relative_index = levels_range.find(loader.extract_level_number(info.path)) + 1
		var location_id = int(GameManager.location_selected)
		var display_number = "%d.%d" % [location_id, relative_index]

		var container = factory.create_level_button(display_number, info.disabled, info.theme)
		level_container.add_child(container)

		var button = container.get_child(0) as Button
		var selector_control = container.get_child(1)
		var selector_label = selector_control.get_node("Selector") as Label

		if button == null or selector_label == null:
			push_warning("Level button factory structure mismatch at index %d" % i)
			continue

		buttons.append(button)
		selectors.append([selector_label])
		base_positions[selector_label] = selector_label.position

	var back_button = $ColorRect/MarginContainer/VBoxContainer/CenterContainer3/HBoxContainer/Button
	var back_selector = [$ColorRect/MarginContainer/VBoxContainer/CenterContainer3/HBoxContainer/SelectorL, $ColorRect/MarginContainer/VBoxContainer/CenterContainer3/HBoxContainer/SelectorR]
	
	buttons.append(back_button)
	selectors.append(back_selector)
	
	await get_tree().process_frame
	for sel in back_selector:
		base_positions[sel] = sel.position
	
	if buttons.size() > 0:
		set_current_selection(0)
	
	setup_mouse()

func is_level_disabled() -> bool:
	return current_selection > GameManager.max_level_reach

func handle_navigation(_event):
	var max_index = buttons.size() - 1  # include anche il back button
		
	if Input.is_action_just_pressed("move_right") and current_selection < max_index:
		SoundManager.play_sfx("res://Assets/Audio/TutorialBtnClick.wav")
		current_selection += 1
	elif Input.is_action_just_pressed("move_left") and current_selection > 0:
		SoundManager.play_sfx("res://Assets/Audio/TutorialBtnClick.wav")
		current_selection -= 1
	elif Input.is_action_just_pressed("move_down") and current_selection < max_index:
		SoundManager.play_sfx("res://Assets/Audio/TutorialBtnClick.wav")
		current_selection = current_selection + ROW_SIZE if current_selection + ROW_SIZE <= max_index else max_index
	elif Input.is_action_just_pressed("move_up") and current_selection > 0:
		SoundManager.play_sfx("res://Assets/Audio/TutorialBtnClick.wav")
		current_selection = current_selection - ROW_SIZE if current_selection - ROW_SIZE >= 0 else 0
	
	set_current_selection(current_selection)

func handle_selection(_index):
	if _index == buttons.size() - 1:
		SoundManager.play_sfx("res://Assets/Audio/DefaultBtnClick.wav")
		get_tree().change_scene_to_file("res://Scenes/UI/LocationSelection.tscn")
		return
	
	if(is_level_disabled()):
		return
	
	var info = loader.get_level_data_for_location(GameManager.location_selected)[_index]
	_on_level_button_pressed(info.path, info.sound)

func _on_level_button_pressed(path: String, _sound: String):
	var level_num = loader.extract_level_number(path)
	GameManager.current_level = level_num

	var is_first_level_of_location = level_num == GameManager.get_level_range_for_location(GameManager.location_selected)[0]
	
	#SoundManager.play_sfx(sound);
	
	if is_first_level_of_location:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		var loader_scene = preload("res://Scenes/UI/TransitionScreen.tscn").instantiate()
		loader_scene.scene_to_load = path
		loader_scene.transition_text = GameManager.Location.keys()[GameManager.get_location_for_level(level_num)]
		loader_scene.location_id = int(GameManager.get_location_for_level(level_num))
		get_tree().root.add_child(loader_scene)
	else:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		get_tree().change_scene_to_file(path)
