extends Control

@onready var level_container: GridContainer = $CanvasLayer/RightPanel/CenterContainer/LevelButtonContainer

func _ready():
	$CanvasLayer/RightPanel/Location.text = GameManager.Location.keys()[GameManager.location_selected]
	load_level_buttons()

func load_level_buttons():
	for child in level_container.get_children():
		child.queue_free()

	var dir = DirAccess.open("res://Scenes/Levels/")
	if not dir:
		return

	var level_files: Array[String] = []
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tscn") and file_name.begins_with("Level"):
			level_files.append(file_name)
		file_name = dir.get_next()
	dir.list_dir_end()

	level_files.sort_custom(func(a: String, b: String) -> bool:
		return extract_level_number(a) < extract_level_number(b)
	)

	for file in level_files:
		var level_num = extract_level_number(file)
		if GameManager.get_location_for_level(level_num) == GameManager.location_selected:
			var level_path = "res://Scenes/Levels/" + file
			create_level_button(str(level_num), level_path)

func create_level_button(label: String, path: String):
	var button := Button.new()
	button.text = label
	button.focus_mode = Control.FOCUS_NONE
	button.disabled = is_level_disabled(label)
	button.pressed.connect(_on_level_button_pressed.bind(path))
	
	# Personalizzazione con match sulla location
	match GameManager.location_selected:
		GameManager.Location.TUTORIAL:
			button.theme = preload("res://Theme/TutorialButton.tres")
		GameManager.Location.DUNGEON:
			button.theme = preload("res://Theme/DungeonButton.tres")
		_:
			# Default fallback (opzionale)
			button.add_theme_color_override("font_color", Color.WHITE)
	
	# Posizionamento
	button.set_size(Vector2(100, 60))
	button.set_custom_minimum_size(Vector2(100, 60))
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	
	level_container.add_child(button)

func _on_level_button_pressed(path: String):
	var level_num = extract_level_number(path)
	GameManager.current_level = level_num

	var is_first_level_of_location = level_num == GameManager.get_level_range_for_location(GameManager.location_selected)[0]
	
	if (is_first_level_of_location):
		var location_key: String = str(GameManager.location_selected + 1)
		var how_to_play_path = "res://Scenes/UI/HowToPlay%s.tscn" % location_key

		if ResourceLoader.exists(how_to_play_path):
			get_tree().change_scene_to_file(how_to_play_path)
			return
		
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		
		var loader = preload("res://Scenes/UI/TransitionScreen.tscn").instantiate()
		loader.scene_to_load = path
		loader.transition_text = GameManager.Location.keys()[GameManager.get_location_for_level(level_num)]
		loader.location_id = int(GameManager.get_location_for_level(level_num))
		get_tree().root.add_child(loader)
	else:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		get_tree().change_scene_to_file(path)

func extract_level_number(filename: String) -> int:
	var level_name = filename.get_basename()
	var digits := ""
	for c in level_name:
		if c in "0123456789":
			digits += c
	return int(digits)

func is_level_disabled(label: String) -> bool:
	var level_number = extract_level_number(label)
	var max_level_reach = GameManager.max_level_reach
	return level_number > max_level_reach

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/LocationSelection.tscn")
