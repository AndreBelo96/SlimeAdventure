extends Node

enum Location { TUTORIAL, DUNGEON, FOREST }

const SPIKE_STEP_TILE_POSITION := 7
const SPIKE_TILE_POSITION := 11
const WALL_TILE_POSITION := 12
const SWITCH_TILE_POSITION := 13
const NUMBER_OF_LEVELS := 13

var location_translation_keys = {
	Location.TUTORIAL: "TUTORIAL_BTN",
	Location.DUNGEON: "DUNGEON_BTN",
	Location.FOREST: "FOREST_BTN"
}

var location_selected = Location.TUTORIAL

var level_locations := {
	1: Location.TUTORIAL, 2: Location.TUTORIAL, 3: Location.TUTORIAL,
	4: Location.DUNGEON, 5: Location.DUNGEON, 6: Location.DUNGEON,
	7: Location.DUNGEON, 8: Location.DUNGEON, 9: Location.DUNGEON,
	10: Location.DUNGEON, 11: Location.DUNGEON, 12: Location.DUNGEON,
	13: Location.DUNGEON, 14: Location.FOREST
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

func is_location_locked(location_name: String) -> bool:
	var location_type = Location[location_name]
	var first_level := _get_first_level_of_location(location_type)
	return first_level > LevelStateManager.max_level_reach

func _get_first_level_of_location(location_type) -> int:
	var min_level = null
	for level in level_locations.keys():
		if level_locations[level] == location_type:
			if min_level == null or level < min_level:
				min_level = level
	return min_level

func get_location_for_level(level: int) -> Location:
	return level_locations.get(level, Location.TUTORIAL)

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
	for level in level_locations:
		if level_locations[level] == loc:
			result.append(level)
	result.sort()
	return result

func is_location_changing(next: int) -> bool:
	var current_loc = get_location_for_level(LevelStateManager.current_level)
	var next_loc = get_location_for_level(next)
	return current_loc != next_loc

func is_dark_level() -> bool:
	return dark_overlay_service.is_dark_level(LevelStateManager.current_level)

func get_dark_overlay_for_level() -> Color:
	return dark_overlay_service.get_for_level(LevelStateManager.current_level)
