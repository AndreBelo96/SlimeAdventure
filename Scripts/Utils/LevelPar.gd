class_name LevelPar
extends RefCounted
## Passi minimi per livello, generati da Tools/PrintPar.gd

const PATH := "res://Data/level_par.json"

enum Rank { NONE, BRONZE, SILVER, GOLD }
const SILVER_RATIO := 1.25   # entro il 25% in più del par
const BRONZE_RATIO := 1.5    # entro il 50% in più

static var _par := {}
static var _loaded := false

## -1 se il livello non ha par (boss, livello non risolto)
static func get_par(level: int) -> int:
	_load()
	return _par.get(level, -1)

static func has_par(level: int) -> bool:
	return get_par(level) > 0

static func get_rank(level: int, steps: int) -> Rank:
	var par := get_par(level)
	if par <= 0 or steps <= 0:
		return Rank.NONE
	if steps <= par:
		return Rank.GOLD
	if steps <= par * SILVER_RATIO:
		return Rank.SILVER
	if steps <= par * BRONZE_RATIO:
		return Rank.BRONZE
	return Rank.NONE

static func _load() -> void:
	if _loaded:
		return
	_loaded = true
	if not FileAccess.file_exists(PATH):
		push_warning("LevelPar: %s non trovato, lancia Tools/PrintPar.gd" % PATH)
		return
	var data = JSON.parse_string(FileAccess.get_file_as_string(PATH))
	if not data is Dictionary:
		return
	var levels: Dictionary = data.get("levels", {})
	for key in levels:
		_par[int(key)] = int(levels[key]["par"])
