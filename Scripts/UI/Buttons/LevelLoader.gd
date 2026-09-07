class_name LevelLoader
extends Object

const LEVELS_PATH := "res://Scenes/Levels/"

func get_all_levels() -> Array[String]:
	var level_files: Array[String] = []
	var dir := DirAccess.open(LEVELS_PATH)
	if dir == null:
		push_error("LevelLoader: impossibile aprire %s" % LEVELS_PATH)
		return level_files

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.begins_with("Level") and file_name.ends_with(".tscn"):
			level_files.append(file_name)
		file_name = dir.get_next()
	dir.list_dir_end()
	return level_files

func get_levels_for_location(loc: int) -> Array[String]:
	var level_files: Array[String] = []

	for file_name in get_all_levels():
		var level_num = extract_level_number(file_name)
		if LocationManager.get_location_for_level(level_num) == loc:
			level_files.append(file_name)

	level_files.sort_custom(func(a, b):
		return extract_level_number(a) < extract_level_number(b)
	)

	return level_files

func get_level_data_for_location(loc: int) -> Array[Dictionary]:
	var levels_info: Array[Dictionary] = []
	var files = get_levels_for_location(loc)
	for file in files:
		var num = extract_level_number(file)
		levels_info.append({
			"number": num,
			"path": "res://Scenes/Levels/" + file,
			"disabled": num > LevelStateManager.max_level_reach,
			"theme": ThemeManager.get_theme_for_location_type(loc),
			"sound": ThemeManager.get_sound_for_location_type(loc)
		})
	return levels_info

func extract_level_number(filename: String) -> int:
	var level_name = filename.get_basename()
	var digits := ""
	for c in level_name:
		if c in "0123456789":
			digits += c
	return int(digits)
