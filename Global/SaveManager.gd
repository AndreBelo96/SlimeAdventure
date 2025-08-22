extends Node

const SAVE_PATH := "user://save_data.save"

## Struttura dati persistente
var save_data := {
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

func update_stats(level: int, steps: int, time: float, deaths: Dictionary, victory: bool) -> bool:
	var is_record := false
	
	if victory:
		is_record = save_progress(level, steps, time)

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
	if not FileAccess.file_exists(SAVE_PATH):
		return save_data
	
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var content := file.get_as_text()
	file.close()
	
	var result: Variant = JSON.parse_string(content)
	if result is Dictionary:
		save_data = result
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

## --- Private --- ##
func _write_file():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data, "\t"))
	file.close()
