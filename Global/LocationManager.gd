extends Node

enum Location { TUTORIAL, DUNGEON, FOREST }

const SPIKE_STEP_TILE_POSITION := 7
const SPIKE_TILE_POSITION := 11
const WALL_TILE_POSITION := 12
const SWITCH_TILE_POSITION := 13

var location_translation_keys = {
	Location.TUTORIAL: "TUTORIAL_BTN",
	Location.DUNGEON: "DUNGEON_BTN",
	Location.FOREST: "FOREST_BTN"
}

var location_boss_level := {
	Location.TUTORIAL: null,
	Location.DUNGEON: 13,
	Location.FOREST: null
}

var location_selected = Location.TUTORIAL

var level_data := {
	1: {"location": Location.TUTORIAL, "name": "Tutorial 1"},
	2: {"location": Location.TUTORIAL, "name": "Tutorial 2"},
	3: {"location": Location.TUTORIAL, "name": "Tutorial 3"},
	4: {"location": Location.DUNGEON, "name": "Segrete"},
	5: {"location": Location.DUNGEON, "name": "Cella"},
	6: {"location": Location.DUNGEON, "name": "Livello 6"},
	7: {"location": Location.DUNGEON, "name": "Livello 7"},
	8: {"location": Location.DUNGEON, "name": "Livello 8"},
	9: {"location": Location.DUNGEON, "name": "Livello 9"},
	10: {"location": Location.DUNGEON, "name": "Livello 10"},
	11: {"location": Location.DUNGEON, "name": "Livello 11"},
	12: {"location": Location.DUNGEON, "name": "Livello 12"},
	13: {"location": Location.DUNGEON, "name": "Sala del Boss"},
	14: {"location": Location.FOREST, "name": "Livello 14"}
}

var location_to_tileset_row := {
	Location.TUTORIAL: 0,
	Location.DUNGEON: 1,
	Location.FOREST: 2
}

var location_background_generator := {
	Location.TUTORIAL: PanelBackgroundGenerator,
	Location.DUNGEON: SkullBackgroundGenerator,
	Location.FOREST: PanelBackgroundGenerator
}

func get_background_generator_for_level(level: int) -> IBackgroundGenerator:
	var loc := get_location_for_level(level)
	var generator_class = location_background_generator.get(loc, PanelBackgroundGenerator)
	return generator_class.new()

var dark_overlay_service := DarkOverlayService.new()

func get_all_locations() -> Array:
	return Location.keys()

func get_number_of_levels() -> int:
	return level_data.size()

func is_location_locked(location_name: String) -> bool:
	var location_type = Location[location_name]
	var first_level := _get_first_level_of_location(location_type)
	return first_level > LevelStateManager.max_level_reach

func _get_first_level_of_location(location_type) -> int:
	var min_level = null
	for level in level_data.keys():
		if level_data[level]["location"] == location_type:
			if min_level == null or level < min_level:
				min_level = level
	return min_level

func get_location_for_level(level: int) -> Location:
	return level_data.get(level, {}).get("location", Location.TUTORIAL)

func get_location_type(location_name: String) -> Location:
	if Location.has(location_name):
		return Location[location_name]
	else:
		return Location.TUTORIAL

func get_tileset_row_for_level() -> int:
	var loc := get_location_for_level(LevelStateManager.current_level)
	return location_to_tileset_row.get(loc, 0)

func get_level_range_for_location(loc: Location) -> Array[int]:
	var result: Array[int] = []
	for level in level_data:
		if level_data[level]["location"] == loc:
			result.append(level)
	result.sort()
	return result

func get_level_name(level: int) -> String:
	return level_data.get(level, {}).get("name", "Livello %d" % level)

func is_location_changing(next: int) -> bool:
	var current_loc = get_location_for_level(LevelStateManager.current_level)
	var next_loc = get_location_for_level(next)
	return current_loc != next_loc

func is_dark_level() -> bool:
	return dark_overlay_service.is_dark_level(LevelStateManager.current_level)

func get_dark_overlay_for_level() -> Color:
	return dark_overlay_service.get_for_level(LevelStateManager.current_level)
