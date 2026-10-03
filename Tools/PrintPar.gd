@tool
extends EditorScript
## Calcola i passi minimi di ogni livello e li scrive in OUTPUT_PATH.
## Script Editor -> File -> Run (Ctrl+Shift+X).
## I livelli non risolvibili (boss, meccaniche non supportate, nessuna soluzione) vengono saltati.

const LEVELS_DIR := "res://Scenes/Levels/"
const OUTPUT_PATH := "res://Data/level_par.json"
const PICKAXE_FROM_LEVEL := 14   # il piccone si ottiene battendo il boss del 13
const VINE_FROM_LEVEL := 24      # PROVVISORIO: livello dopo il boss Foresta

func _run() -> void:
	var levels := {}
	var t0 := Time.get_ticks_msec()
	for n in _level_numbers():
		var path := LEVELS_DIR + "Level%d.tscn" % n
		var r := _solve(path, n >= PICKAXE_FROM_LEVEL, n >= VINE_FROM_LEVEL)
		if r.has("par"):
			levels[str(n)] = {"par": r.par, "keys": r.keys}
			print("Livello %d: %d passi  (%d stati, %d ms)" % [n, r.par, r.states, r.ms])
			print("    tasti: ", r.keys)
		else:
			print("Livello %d: SALTATO - %s" % [n, r.reason])

	_write(levels)
	print("\nScritti %d livelli in %s (%d ms totali)" % [levels.size(), OUTPUT_PATH, Time.get_ticks_msec() - t0])

func _solve(path: String, pickaxe: bool, vine: bool) -> Dictionary:
	var root: Node = load(path).instantiate()
	var model := LevelModel.from_scene(root, pickaxe, vine)
	root.free()
	if not model.unsupported.is_empty():
		return {"reason": "non supportato (%s)" % ", ".join(model.unsupported)}

	var t := Time.get_ticks_msec()
	var solver := StepSolver.new()
	var res := solver.solve(model)
	if res.steps < 0:
		return {"reason": res.reason}
	return {
		"par": res.steps,
		"keys": StepSolver.directions_text(res.path),
		"states": solver.states_explored,
		"ms": Time.get_ticks_msec() - t,
	}

## Numeri dei file LevelN.tscn (LevelTest e simili esclusi), in ordine
func _level_numbers() -> Array[int]:
	var out: Array[int] = []
	for file in DirAccess.get_files_at(LEVELS_DIR):
		if not file.begins_with("Level") or not file.ends_with(".tscn"):
			continue
		var num := file.trim_prefix("Level").trim_suffix(".tscn")
		if num.is_valid_int():
			out.append(num.to_int())
	out.sort()
	return out

func _write(levels: Dictionary) -> void:
	DirAccess.make_dir_recursive_absolute(OUTPUT_PATH.get_base_dir())
	var file := FileAccess.open(OUTPUT_PATH, FileAccess.WRITE)
	if file == null:
		push_error("PrintPar: impossibile scrivere %s" % OUTPUT_PATH)
		return
	file.store_string(JSON.stringify({
		"generated_at": Time.get_datetime_string_from_system(),
		"levels": levels,
	}, "\t"))
	file.close()
	EditorInterface.get_resource_filesystem().scan()
