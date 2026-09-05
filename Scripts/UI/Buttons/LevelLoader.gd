class_name LevelLoader
extends Object

const ALL_LEVELS := [
	"Level1.tscn",
	"Level2.tscn",
	"Level3.tscn",
	"Level4.tscn",
	"Level5.tscn",
	"Level6.tscn",
	"Level7.tscn",
	"Level8.tscn",
	"Level9.tscn",
	"Level10.tscn",
	"Level11.tscn",
	"Level12.tscn",
	"Level13.tscn",
]

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

func get_levels_for_location(loc: int) -> Array[String]:

	var level_files: Array[String] = []
	
	for file_name in ALL_LEVELS:
		if file_name.ends_with(".tscn") and file_name.begins_with("Level"):
			var level_num = extract_level_number(file_name)
			if LocationManager.get_location_for_level(level_num) == loc:
				level_files.append(file_name)

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
