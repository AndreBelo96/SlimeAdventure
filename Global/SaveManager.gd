extends Node

var current_slot : int = 1

## Struttura dati persistente
var save_data := get_default_save_data()

## --- Public API --- ##

func save_progress(level: int, steps: int, time: float) -> bool:
	var level_key = str(level)
	var is_record := false

	if not save_data["levels"].has(level_key):
		save_data["levels"][level_key] = {"steps": steps, "time": time}
		is_record = true
	else:
		var old_data = save_data["levels"][level_key]
		if steps < old_data["steps"] or time < old_data["time"]:
			is_record = true
		
		save_data["levels"][level_key]["steps"] = min(old_data["steps"], steps)
		save_data["levels"][level_key]["time"] = min(old_data["time"], time)
	
	save_data["max_level_reach"] = max(save_data["max_level_reach"], level + 1)
	_write_file()
	return is_record

func update_stats(level: int, steps: int, time: float, deaths: Dictionary, victory: bool, _has_pickaxe: bool) -> bool:
	var is_record := false
	
	if victory:
		is_record = save_progress(level, steps, time)
		save_data["player"]["has_pickaxe"] = _has_pickaxe

	save_data["total_steps"] += steps
	save_data["total_time"] += time

	for death_type in deaths.keys():
		var key = str(death_type)
		if not save_data["death_counts"].has(key):
			save_data["death_counts"][key] = 0
		save_data["death_counts"][key] += deaths[death_type]

	_write_file()
	return is_record

func load_progress() -> Dictionary:
	print("Loading slot:", current_slot)
	print("Path:", get_save_path())
	
	if not FileAccess.file_exists(get_save_path()):
		print("Save NOT found")
		save_data = get_default_save_data()
		return save_data
	
	print("Save FOUND")
	
	var file := FileAccess.open(get_save_path(), FileAccess.READ)
	var content := file.get_as_text()
	file.close()
	
	var result: Variant = JSON.parse_string(content)
	if result is Dictionary:
		save_data = result
	
	if not save_data.has("player"):
		save_data["player"] = {"has_pickaxe": false}
	
	print(content)
	
	return save_data

func reset_save():
	save_data = {
		"levels": {},
		"max_level_reach": 1,
		"total_steps": 0,
		"total_time": 0.0,
		"death_counts": {"0":0,"1":0,"2":0,"3":0}
	}
	_write_file()

## --- Utils --- ##
func get_max_level_reach() -> int:
	return save_data.get("max_level_reach", 1)

func get_level_data(level: int) -> Dictionary:
	return save_data["levels"].get(str(level), {})

func get_totals() -> Dictionary:
	return {
		"steps": save_data.get("total_steps", 0),
		"time": save_data.get("total_time", 0.0),
		"deaths": save_data.get("death_counts", {})
	}

func has_pickaxe() -> bool:
	return save_data.get("player", {}).get("has_pickaxe", false)

func get_default_save_data() -> Dictionary:
	return {
		"created_at": Time.get_unix_time_from_system(),
		"last_played": Time.get_unix_time_from_system(),
		"player": {                  # dati giocatore
			"has_pickaxe": false
		},
		"levels": {},                # dati per livello
		"max_level_reach": 1,        # livello massimo sbloccato
		"total_steps": 0,            # passi totali
		"total_time": 0.0,           # tempo totale giocato
		"death_counts": {            # morti globali divise per tipo
			"0": 0,   # DeathType.SPIKES
			"1": 0,   # DeathType.VOID
			"2": 0,   # DeathType.ENEMY
			"3": 0    # DeathType.TIMEOUT
		}
	}

#C:\Users\Andrea\AppData\Roaming\Godot\app_userdata\Slime Adventure
func get_save_path() -> String:
	return "user://save_slot_%d.save" % current_slot

func slot_exists(slot:int) -> bool:
	var path = "user://save_slot_%d.save" % slot
	return FileAccess.file_exists(path)

## --- Private --- ##
func _write_file():
	var file = FileAccess.open(get_save_path(), FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data, "\t"))
	file.close()
