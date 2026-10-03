@tool
extends RefCounted
class_name StepSolver
## BFS sullo stato (cella, activator accesi, chiavi premute, fase temporale).
## Stato = ((indice_cella << BIT) | maschera) * periodo + fase
## maschera = [chiavi premute | activator accesi], BIT = n_activator + n_chiavi

const MAX_STATES := 16_000_000
const UNVISITED := -2
const ROOT := -1

const ARROWS := {Vector2i(0, -1): "↑", Vector2i(1, 0): "→", Vector2i(0, 1): "↓", Vector2i(-1, 0): "←"}

var states_explored := 0

var _cells: Array[Vector2i] = []
var _bits := 0
var _period := 1

func solve(m: LevelModel) -> Dictionary:
	var n_act := m.activators.size()
	if n_act == 0:
		return _fail("nessun activator")
	_bits = m.state_bits()
	_period = m.period

	_cells.clear()
	var index := {}
	for c in m.cells:
		index[c] = _cells.size()
		_cells.append(c)

	var act_full := (1 << n_act) - 1
	var total := (_cells.size() << _bits) * _period
	if total > MAX_STATES:
		return _fail("troppi stati (%d)" % total)

	# Allo spawn il player "entra" nella sua cella (check_tile in Player._ready)
	var mask0 := 0
	if m.activator_bit.has(m.start):
		mask0 |= 1 << m.activator_bit[m.start]
	if m.switch_key.has(m.start):
		mask0 |= m.key_bit(m.switch_key[m.start])
	if m.is_deadly(m.start, 0, 0):
		return _fail("partenza su vuoto o spina")
	if (mask0 & act_full) == act_full and m.exit_cell == null:
		return {"steps": 0, "path": [m.start]}

	var prev := PackedInt32Array()
	prev.resize(total)
	prev.fill(UNVISITED)

	var start_state := _encode(index[m.start], mask0, 0)
	prev[start_state] = ROOT
	var frontier := PackedInt32Array([start_state])
	var steps := 0
	states_explored = 1

	while not frontier.is_empty():
		steps += 1
		var phase := steps % _period
		var next := PackedInt32Array()
		for s in frontier:
			var cell := _cell_of(s)
			var mask := _mask_of(s)
			var all_on := (mask & act_full) == act_full   # activator bloccati, porte aperte
			for dir in LevelModel.DIRS:
				var to := cell + dir
				# Le spine guardano le chiavi premute PRIMA di questo passo
				if not m.can_step(cell, to, all_on) or m.is_deadly(to, steps, mask):
					continue
				# Come in gioco: il controllo uscita avviene PRIMA che la tile cambi stato
				var reached_exit: bool = all_on and m.exit_cell != null and to == m.exit_cell
				var new_mask := mask
				if not all_on and m.activator_bit.has(to):
					new_mask ^= 1 << m.activator_bit[to]
				if m.switch_key.has(to):
					new_mask |= m.key_bit(m.switch_key[to])
				var ns := _encode(index[to], new_mask, phase)
				if reached_exit or ((new_mask & act_full) == act_full and m.exit_cell == null):
					if prev[ns] == UNVISITED:
						prev[ns] = s
					return {"steps": steps, "path": _path(prev, ns)}
				if prev[ns] != UNVISITED:
					continue
				prev[ns] = s
				next.append(ns)
				states_explored += 1
		frontier = next
	return _fail("nessuna soluzione")

# ---------- Codifica dello stato ----------
func _encode(cell_idx: int, mask: int, phase: int) -> int:
	return ((cell_idx << _bits) | mask) * _period + phase

@warning_ignore("integer_division")
func _cell_of(s: int) -> Vector2i:
	return _cells[(s / _period) >> _bits]

@warning_ignore("integer_division")
func _mask_of(s: int) -> int:
	return (s / _period) & ((1 << _bits) - 1)

func _path(prev: PackedInt32Array, s: int) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	while s != ROOT:
		out.push_front(_cell_of(s))
		s = prev[s]
	return out

func _fail(reason: String) -> Dictionary:
	return {"steps": -1, "reason": reason}
## Percorso di celle -> direzioni (= i tasti da premere)
static func to_directions(path: Array[Vector2i]) -> Array[Vector2i]:
	var dirs: Array[Vector2i] = []
	for i in range(1, path.size()):
		dirs.append(path[i] - path[i - 1])
	return dirs

## Es. "↑3 →2 ↓1"
static func directions_text(path: Array[Vector2i]) -> String:
	var parts: Array[String] = []
	var dirs := to_directions(path)
	var i := 0
	while i < dirs.size():
		var count := 1
		while i + count < dirs.size() and dirs[i + count] == dirs[i]:
			count += 1
		parts.append("%s%d" % [ARROWS.get(dirs[i], "?"), count])
		i += count
	return " ".join(parts)
