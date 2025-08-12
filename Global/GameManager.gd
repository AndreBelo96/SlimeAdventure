# Scripts/GameManager.gd
extends Node

enum Location { TUTORIAL, DUNGEON, FOREST }
## Current variables
var current_level: int = 1
var current_time: float = 0.0
var current_steps: int = 0
## Total Variables
var max_level_reach: int = 1
var total_time: float = 0.0
var total_steps: int = 0
var isRecord: bool = false
## Level Variables
const NORMAL_TILE_POSITION := 7
const SPIKE_STEP_TILE_POSITION := 8
const SPIKE_TILE_POSITION := 12
const WALL_TILE_POSITION := 13
const BORDER_TILE_POSITION := 14
const FLIP_BORDER_TILE_POSITION := 15
const SWITCH_TILE_POSITION := 16
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

## Save Variables
const SAVE_PATH := "user://save_data.save"
var save_data := {
	"levels": {},
	"max_level_reach": 1
}

func _ready():
	load_progress()

# -- save data -- #

func save_progress(level: int, steps: int, time: float):
	# Aggiorna solo se è un miglioramento
	var level_key = str(level)

	if not save_data["levels"].has(level_key):
		save_data["levels"][level_key] = {"steps": steps, "time": time}
		isRecord = true
	else:
		var old_data = save_data["levels"][level_key]
		
		if steps < old_data["steps"] || time < old_data["time"]:
			isRecord = true
		
		save_data["levels"][level_key]["steps"] = min(old_data["steps"], steps)
		save_data["levels"][level_key]["time"] = min(old_data["time"], time)
	
	save_data["max_level_reach"] = max(save_data["max_level_reach"], level+1)
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data, "\t"))
	file.close()

	print("Salvataggio aggiornato per livello", level)

func load_progress():
	if not FileAccess.file_exists(SAVE_PATH):
		print("Nessun file di salvataggio trovato")
		return
	
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var content := file.get_as_text()
	file.close()
	
	var result: Variant = JSON.parse_string(content)
	if result is Dictionary:
		# Carica l'intera struttura nel save_data
		save_data = result
		# Se vogliamo usare direttamente valori comodi per compatibilità
		if save_data.has("max_level_reach"):
			max_level_reach = save_data["max_level_reach"]
		# Esempio: calcolo dei totali ricavandoli dai dati salvati per livello
		if save_data.has("levels"):
			total_steps = 0
			total_time = 0.0
			for level_data in save_data["levels"].values():
				total_steps += int(level_data.get("steps", 0))
				total_time += float(level_data.get("time", 0.0))
		print("Salvataggio caricato con successo")
	else:
		print("Errore nel parsing JSON")

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

func next_level():
	current_level += 1
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

func restart_level():
	get_tree().change_scene_to_file("res://Scenes/Levels/Level%d.tscn" % current_level)

func return_to_menu():
	get_tree().change_scene_to_file("res://Scenes/UI/MainMenu.tscn")

func reset_game():
	current_level = 1
	total_time = 0.0
	total_steps = 0
	get_tree().change_scene_to_file("res://Scenes/Level1.tscn")
