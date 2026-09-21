extends Node

enum Location { TUTORIAL, DUNGEON, FOREST }

const SPIKE_STEP_TILE_POSITION := 7
const SPIKE_TILE_POSITION := 11
const WALL_TILE_POSITION := 12
const SWITCH_TILE_POSITION := 13

const PICKUP_SPRITESHEET := preload("res://Assets/Sprites/Pickups/pickups_set.png")

var location_selected = Location.TUTORIAL
var dark_overlay_service := DarkOverlayService.new()

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

var location_data := {
	Location.TUTORIAL: {
		"translation_key": "TUTORIAL_BTN",
		"boss_level": null,
		"boss_reward": null,
		"boss_portrait": null,
		"tileset_row": 0,
		"background_generator": PanelBackgroundGenerator
	},
	Location.DUNGEON: {
		"translation_key": "DUNGEON_BTN",
		"boss_level": 13,
		"boss_reward": "pickaxe",
		"boss_portrait": "Ludovico",
		"tileset_row": 1,
		"background_generator": SkullBackgroundGenerator
	},
	Location.FOREST: {
		"translation_key": "FOREST_BTN",
		"boss_level": null,
		"boss_reward": null,
		"boss_portrait": null,
		"tileset_row": 2,
		"background_generator": PanelBackgroundGenerator
	}
}

var boss_reward_icons := {
	"pickaxe": Rect2(64, 0, 32, 32)
	# aggiungi qui la region del prossimo reward quando arriva
}

func get_background_generator_for_level(level: int) -> IBackgroundGenerator:
	var loc := get_location_for_level(level)
	var generator_class = location_data.get(loc, {}).get("background_generator", PanelBackgroundGenerator)
	return generator_class.new()

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

func get_translation_key(loc: Location) -> String:
	return location_data.get(loc, {}).get("translation_key", "")

func get_boss_level(loc: Location):
	return location_data.get(loc, {}).get("boss_level", null)

func get_boss_portrait(loc: Location):
	return location_data.get(loc, {}).get("boss_portrait", null)

func get_boss_reward(loc: Location):
	return location_data.get(loc, {}).get("boss_reward", null)

func get_tileset_row(loc: Location) -> int:
	return location_data.get(loc, {}).get("tileset_row", 0)

func get_tileset_row_for_level(level: int = -1) -> int:
	if level < 0:
		level = LevelStateManager.current_level
	return get_tileset_row(get_location_for_level(level))

func get_level_range_for_location(loc: Location) -> Array[int]:
	var result: Array[int] = []
	for level in level_data:
		if level_data[level]["location"] == loc:
			result.append(level)
	result.sort()
	return result

func get_level_name(level: int) -> String:
	var key: String = level_data.get(level, {}).get("name_key", "")
	if key != "":
		return tr(key)
	return tr("LEVEL_N") % level

func is_location_changing(next: int) -> bool:
	var current_loc = get_location_for_level(LevelStateManager.current_level)
	var next_loc = get_location_for_level(next)
	return current_loc != next_loc

func is_dark_level() -> bool:
	return dark_overlay_service.is_dark_level(LevelStateManager.current_level)

func get_dark_overlay_for_level() -> Color:
	return dark_overlay_service.get_for_level(LevelStateManager.current_level)
