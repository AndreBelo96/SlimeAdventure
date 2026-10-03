@tool
extends EditorScript

const LEVELS := [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
const PICKAXE_FROM_LEVEL := 14   # il piccone si ottiene battendo il boss del 13
const VINE_FROM_LEVEL := 24      # PROVVISORIO: livello dopo il boss Foresta
## Scene di test: [path, piccone, liana]
const EXTRA := [
	# ["res://Scenes/Levels/LevelTestSolver.tscn", true, true],
]

func _run() -> void:
	for n in LEVELS:
		_report("Livello %d" % n, "res://Scenes/Levels/Level%d.tscn" % n,
			n >= PICKAXE_FROM_LEVEL, n >= VINE_FROM_LEVEL)
	for e in EXTRA:
		_report(e[0].get_file(), e[0], e[1], e[2])

func _report(label: String, path: String, pickaxe: bool, vine: bool) -> void:
	var root: Node = load(path).instantiate()
	var model := LevelModel.from_scene(root, pickaxe, vine)
	root.free()

	if not model.unsupported.is_empty():
		print("%s: non supportato (%s)" % [label, ", ".join(model.unsupported)])
		return

	var t := Time.get_ticks_msec()
	var solver := StepSolver.new()
	var res := solver.solve(model)
	var ms := Time.get_ticks_msec() - t
	if res.steps < 0:
		print("%s: %s" % [label, res.reason])
	else:
		print("%s: %d passi  (%d activator, %d stati, %d ms)" % [label, res.steps, model.activators.size(), solver.states_explored, ms])
		print("    tasti: ", StepSolver.directions_text(res.path))
