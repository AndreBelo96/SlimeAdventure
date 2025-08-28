# Scripts/GameManager.gd
extends Node

## Level Variables
const DeathType = preload("res://Scripts/Player/DeathType.gd").DeathType
const NORMAL_TILE_POSITION := 7
const SPIKE_STEP_TILE_POSITION := 8
const SPIKE_TILE_POSITION := 12
const WALL_TILE_POSITION := 13
const BORDER_TILE_POSITION := 14
const FLIP_BORDER_TILE_POSITION := 15
const SWITCH_TILE_POSITION := 16

enum Location { TUTORIAL, DUNGEON, FOREST }
## Variabili correnti
var current_level: int = 1
var current_time: float = 0.0
var current_steps: int = 0
var isRecord: bool = false
## Totali caricati da SaveManager
var max_level_reach: int = 1
var total_time: float = 0.0
var total_steps: int = 0
var total_deaths: Dictionary = {}

var dark_overlay_service := DarkOverlayService.new()

var location_selected = Location.TUTORIAL
var level_locations := {
	1: Location.TUTORIAL,
	2: Location.TUTORIAL,
	3: Location.TUTORIAL,
	4: Location.DUNGEON,
	5: Location.DUNGEON,
	6: Location.DUNGEON,
	7: Location.DUNGEON,
	8: Location.DUNGEON,
	9: Location.DUNGEON,
	10: Location.DUNGEON,
	11: Location.DUNGEON,
	12: Location.DUNGEON,
	13: Location.DUNGEON,
	14: Location.FOREST
}

var location_to_tileset_row := {
	Location.TUTORIAL: 0,
	Location.DUNGEON: 1,
	Location.FOREST: 2
}

var death_counts := {
	DeathType.SPIKES: 0,
	DeathType.VOID: 0,
	DeathType.ENEMY: 0,
	DeathType.TIMEOUT: 0
}

var last_attempt := {
	"level": 1,
	"steps": 0,
	"time": 0.0,
	"deaths": {
		DeathType.SPIKES: 0,
		DeathType.VOID: 0,
		DeathType.ENEMY: 0,
		DeathType.TIMEOUT: 0
	},
	"victory": false,
	"is_record": false
}

func _ready():
	var _loaded = SaveManager.load_progress()
	max_level_reach = SaveManager.get_max_level_reach()
	var totals = SaveManager.get_totals()
	total_steps = totals.steps
	total_time = totals.time
	total_deaths = totals.deaths

# --- Gestione Morti ---
func register_death(death_type: int):
	if death_type in death_counts:
		death_counts[death_type] += 1
	else:
		death_counts[death_type] = 1

func change_scene_to_victory():
	get_tree().change_scene_to_file("res://Scenes/UI/Victory.tscn")

func change_scene_to_defeat():
	get_tree().change_scene_to_file("res://Scenes/UI/Defeat.tscn")

# --- Fine livello ---
func end_level(victory: bool):
	# Salva statistiche del livello
	last_attempt["level"] = current_level
	last_attempt["steps"] = current_steps
	last_attempt["time"] = current_time
	last_attempt["deaths"] = death_counts.duplicate(true)
	last_attempt["victory"] = victory
	
	isRecord = SaveManager.update_stats(current_level, current_steps, current_time, death_counts, victory)
	last_attempt["is_record"] = isRecord

	# reset conteggio morti per prossimo livello
	death_counts = {
		DeathType.SPIKES: 0,
		DeathType.VOID: 0,
		DeathType.ENEMY: 0,
		DeathType.TIMEOUT: 0
	}

	if victory:
		current_level += 1

	current_steps = 0
	current_time = 0.0

# -- Locations -- #

func get_all_locations() -> Array:
	return Location.keys()

func is_location_locked(location_name: String) -> bool:
	var location_type = Location[location_name]
	var first_level := _get_first_level_of_location(location_type)
	return first_level > max_level_reach

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

# -- Levels -- #

func get_death_count(death_type: int) -> int:
	return death_counts.get(death_type, 0)

func get_tileset_row_for_level() -> int:
	var loc := get_location_for_level(current_level)
	return location_to_tileset_row.get(loc, 0)

func get_level_range_for_location(loc: Location) -> Array[int]:
	var result: Array[int] = []
	for level in level_locations:
		if level_locations[level] == loc:
			result.append(level)
	result.sort()
	return result

func is_location_changing(next: int) -> bool:
	var current_loc = get_location_for_level(current_level)
	var next_loc = get_location_for_level(next)
	return current_loc != next_loc

func is_dark_level() -> bool:
	return current_level in [4, 5, 6, 7, 8, 9, 10, 11, 12, 13]

func next_level():
	var scene_path = "res://Scenes/Levels/Level%d.tscn" % current_level
	
	if current_level > max_level_reach:
		max_level_reach = current_level
	current_steps = 0
	current_time = 0.0
	
	var previous_level = current_level-1
	
	if is_location_changing(previous_level):
		var loader = preload("res://Scenes/UI/TransitionScreen.tscn").instantiate()
		loader.scene_to_load = scene_path
		loader.transition_text = Location.keys()[get_location_for_level(current_level)]
		loader.location_id = int(get_location_for_level(current_level))
		get_tree().root.add_child(loader)
	else:
		get_tree().change_scene_to_file(scene_path)

func get_dark_overlay_for_level() -> Color:
	return dark_overlay_service.get_for_level(current_level)

func restart_level():
	get_tree().change_scene_to_file("res://Scenes/Levels/Level%d.tscn" % current_level)

func return_to_menu():
	get_tree().change_scene_to_file("res://Scenes/UI/MainMenu.tscn")

func reset_game():
	current_level = 1
	total_time = 0.0
	total_steps = 0
	get_tree().change_scene_to_file("res://Scenes/Level1.tscn")
