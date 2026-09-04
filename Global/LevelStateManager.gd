extends Node

var current_level: int = 1
var current_time: float = 0.0
var current_steps: int = 0
var isRecord: bool = false

var max_level_reach: int = 1
var total_time: float = 0.0
var total_steps: int = 0
var total_deaths: Dictionary = {}

var current_save_slot: int = 1
var has_pickaxe = false

var death_counts := {
	DeathType.Type.SPIKES: 0,
	DeathType.Type.VOID: 0,
	DeathType.Type.ENEMY: 0,
	DeathType.Type.TIMEOUT: 0
}

var last_attempt := {
	"level": 1, "steps": 0, "time": 0.0,
	"deaths": {
		DeathType.Type.SPIKES: 0, DeathType.Type.VOID: 0,
		DeathType.Type.ENEMY: 0, DeathType.Type.TIMEOUT: 0
	},
	"victory": false, "is_record": false
}

func reload_save_data():
	max_level_reach = SaveManager.get_max_level_reach()
	var totals = SaveManager.get_totals()
	has_pickaxe = SaveManager.has_pickaxe()
	total_steps = totals.steps
	total_time = totals.time
	total_deaths = totals.deaths

func register_death(death_type: int):
	if death_type in death_counts:
		death_counts[death_type] += 1
	else:
		death_counts[death_type] = 1

func end_level(victory: bool):
	last_attempt["level"] = current_level
	last_attempt["steps"] = current_steps
	last_attempt["time"] = current_time
	last_attempt["deaths"] = death_counts.duplicate(true)
	last_attempt["victory"] = victory

	isRecord = SaveManager.update_stats(current_level, current_steps, current_time, death_counts, victory, has_pickaxe)
	last_attempt["is_record"] = isRecord

	death_counts = {
		DeathType.Type.SPIKES: 0, DeathType.Type.VOID: 0,
		DeathType.Type.ENEMY: 0, DeathType.Type.TIMEOUT: 0
	}

	if victory:
		current_level += 1

	current_steps = 0
	current_time = 0.0

func get_death_count(death_type: int) -> int:
	return death_counts.get(death_type, 0)
