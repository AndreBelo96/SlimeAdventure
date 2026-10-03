@tool
extends RefCounted
class_name StepSolver
## BFS sullo stato (cella, activator accesi, chiavi premute, armatura, fase temporale).
## Stato = ((indice_cella << BIT) | maschera) * periodo + fase
## maschera = [armatura | chiavi premute | activator accesi]

const MAX_STATES := 16_000_000
const UNVISITED := -2
const ROOT := -1
const DEAD := -1

const ARROWS := {Vector2i(0, -1): "↑", Vector2i(1, 0): "→", Vector2i(0, 1): "↓", Vector2i(-1, 0): "←"}

var states_explored := 0

var _cells: Array[Vector2i] = []
var _bits := 0
var _period := 1
var _armor := 0

func solve(m: LevelModel) -> Dictionary:
	var n_act := m.activators.size()
	if n_act == 0:
		return _fail("nessun activator")
	_bits = m.state_bits()
	_period = m.period
	_armor = m.armor_bit()

	_cells.clear()
	var index := {}
	for c in m.cells:
		index[c] = _cells.size()
		_cells.append(c)

	var act_full := (1 << n_act) - 1
	var total := (_cells.size() << _bits) * _period
	if total > MAX_STATES:
		return _fail("troppi stati (%d)" % total)

	# Allo spawn il player "entra" nella sua cella (check_tile in Player._ready, niente pickup)
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
			for to in _destinations(m, cell, all_on):
				var new_mask := _enter(m, to, steps, mask, all_on)
				if new_mask == DEAD:
					continue
				# Come in gioco: il controllo uscita avviene PRIMA che la tile cambi stato
				var reached_exit: bool = all_on and m.exit_cell != null and to == m.exit_cell
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

## Celle raggiungibili con una mossa: passo normale o salto con la liana
func _destinations(m: LevelModel, cell: Vector2i, all_on: bool) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for dir in LevelModel.DIRS:
		var to := cell + dir
		if m.can_step(cell, to, all_on):
			out.append(to)
		if m.has_vine:
			var v = m.vine_target(cell, dir, all_on)
			if v != null and not out.has(v):
				out.append(v)
	return out

## Maschera dopo essere entrati in `to` al passo `step`, DEAD se si muore.
## Ordine del gioco: check_tile (spine guardano le chiavi di PRIMA) -> activator/switch -> check_pickup
func _enter(m: LevelModel, to: Vector2i, step: int, mask: int, all_on: bool) -> int:
	var new_mask := mask
	if m.is_deadly(to, step, mask):
		if (mask & _armor) == 0 or not m.can_absorb(to):
			return DEAD
		new_mask &= ~_armor
	if not all_on and m.activator_bit.has(to):
		new_mask ^= 1 << m.activator_bit[to]
	if m.switch_key.has(to):
		new_mask |= m.key_bit(m.switch_key[to])
	if m.armor_pickups.has(to):
		new_mask |= _armor
	return new_mask

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

## Percorso di celle -> spostamenti. Lunghezza 1 = passo, 2 = salto con la liana.
static func to_directions(path: Array[Vector2i]) -> Array[Vector2i]:
	var dirs: Array[Vector2i] = []
	for i in range(1, path.size()):
		dirs.append(path[i] - path[i - 1])
	return dirs

static func is_vine_move(delta: Vector2i) -> bool:
	return absi(delta.x) + absi(delta.y) > 1

## Es. "↑3 →2 ~↓1" (~ = liana)
static func directions_text(path: Array[Vector2i]) -> String:
	var parts: Array[String] = []
	var dirs := to_directions(path)
	var i := 0
	while i < dirs.size():
		var count := 1
		while i + count < dirs.size() and dirs[i + count] == dirs[i]:
			count += 1
		var prefix := "~" if is_vine_move(dirs[i]) else ""
		parts.append("%s%s%d" % [prefix, ARROWS.get(dirs[i].sign(), "?"), count])
		i += count
	return " ".join(parts)
