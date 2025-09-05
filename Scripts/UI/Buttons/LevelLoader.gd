class_name LevelLoader
extends Object

const THEME_TUTORIAL := preload("res://Theme/TutorialButton.tres")
const THEME_DUNGEON := preload("res://Theme/DungeonButton.tres")
const THEME_DEFAULT := preload("res://Theme/DefaultButton.tres")

const SOUND_TUTORIAL := "res://Assets/Audio/TutorialBtnClick.wav"
const SOUND_DUNGEON := "res://Assets/Audio/TutorialBtnClick.wav" #TODO da fare
const SOUND_DEFAULT := "res://Assets/Audio/DefaultBtnClick.wav"

func get_level_data_for_location(loc: int) -> Array[Dictionary]:
	var levels_info: Array[Dictionary] = []
	var files = get_levels_for_location(loc)
	for file in files:
		var num = extract_level_number(file)
		levels_info.append({
			"number": num,
			"path": "res://Scenes/Levels/" + file,
			"disabled": num > GameManager.max_level_reach,
			"theme": get_theme_for_location(loc),
			"sound": get_sound_for_location(loc)
		})
	return levels_info

func get_sound_for_location(loc: int) -> String:
	match loc:
		GameManager.Location.TUTORIAL:
			return SOUND_TUTORIAL
		GameManager.Location.DUNGEON:
			return SOUND_DUNGEON
		_:
			return SOUND_DEFAULT

func get_theme_for_location(loc: int) -> Theme:
	match loc:
		GameManager.Location.TUTORIAL:
			return THEME_TUTORIAL
		GameManager.Location.DUNGEON:
			return THEME_DUNGEON
		_:
			return THEME_DEFAULT

func get_levels_for_location(loc: int) -> Array[String]:
	var dir = DirAccess.open("res://Scenes/Levels/")
	if not dir:
		return []

	var level_files: Array[String] = []
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tscn") and file_name.begins_with("Level"):
			var level_num = extract_level_number(file_name)
			if GameManager.get_location_for_level(level_num) == loc:
				level_files.append(file_name)
		file_name = dir.get_next()
	dir.list_dir_end()

	# Ordina per numero di livello
	level_files.sort_custom(func(a, b):
		return extract_level_number(a) < extract_level_number(b)
	)

	return level_files

func extract_level_number(filename: String) -> int:
	var level_name = filename.get_basename()
	var digits := ""
	for c in level_name:
		if c in "0123456789":
			digits += c
	return int(digits)
