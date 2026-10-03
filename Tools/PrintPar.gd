@tool
extends EditorScript

const LEVELS := [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
const PICKAXE_FROM_LEVEL := 14   # il piccone si ottiene battendo il boss del 13

func _run() -> void:
	for n in LEVELS:
		var root: Node = load("res://Scenes/Levels/Level%d.tscn" % n).instantiate()
		var model := LevelModel.from_scene(root, n >= PICKAXE_FROM_LEVEL)
		root.free()

		if not model.unsupported.is_empty():
			print("Livello %d: non supportato (%s)" % [n, ", ".join(model.unsupported)])
			continue

		var t := Time.get_ticks_msec()
		var solver := StepSolver.new()
		var res := solver.solve(model)
		var ms := Time.get_ticks_msec() - t
		if res.steps < 0:
			print("Livello %d: %s" % [n, res.reason])
		else:
			print("Livello %d: %d passi  (%d activator, %d stati, %d ms)" % [n, res.steps, model.activators.size(), solver.states_explored, ms])
			print("    tasti: ", StepSolver.directions_text(res.path))
