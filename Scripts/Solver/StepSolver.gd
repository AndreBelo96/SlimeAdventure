@tool
extends RefCounted
class_name StepSolver
## BFS sugli stati del livello. Stato codificato in un intero a base mista:
##   ((cella * 2^BIT + maschera) * periodo + fase) * N_NEMICI + codice_nemici
## maschera = [sassi rotti | armatura | chiavi premute | activator accesi]
## codice_nemici = per ogni nemico 0 (morto) oppure (cella, indice pattern, vita, carica)

const MAX_STATES := 10_000_000   # stati ESPLORATI (circa 100-150 byte l'uno)
const MAX_CODE := 4.0e18
const ROOT := -1
const DEAD := -1

const ARROWS := {Vector2i(0, -1): "↑", Vector2i(1, 0): "→", Vector2i(0, 1): "↓", Vector2i(-1, 0): "←"}

var states_explored := 0

var _m: LevelModel
var _cells: Array[Vector2i] = []
var _index := {}
var _flag_radix := 1
var _period := 1
var _armor := 0
var _enemy_radix: Array[int] = []
var _enemy_total := 1

func solve(m: LevelModel) -> Dictionary:
	_m = m
	var n_act := m.activators.size()
	if n_act == 0:
		return _fail("nessun activator")
	_period = m.period
	_armor = m.armor_flag
	_flag_radix = 1 << m.state_bits()

	_cells.clear()
	_index.clear()
	for c in m.cells:
		_index[c] = _cells.size()
		_cells.append(c)

	_enemy_radix.clear()
	var size := float(_cells.size()) * _flag_radix * _period
	for i in m.enemies.size():
		var r: int = 1 + _cells.size() * _plen(i) * _hp_max(i) * _crad(i)
		_enemy_radix.append(r)
		size *= r
	if size > MAX_CODE:
		return _fail("stato troppo grande da codificare (troppi nemici o activator)")
	_enemy_total = 1
	for r in _enemy_radix:
		_enemy_total *= r

	var act_full := (1 << n_act) - 1

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

	var enemies0 := []
	for i in m.enemies.size():
		enemies0.append([_hp_max(i), m.enemies[i].start, 0, 0])

	var start_state := _encode(_index[m.start], mask0, 0, _encode_enemies(enemies0))
	var prev := {start_state: ROOT}
	var frontier := PackedInt64Array([start_state])
	var steps := 0
	states_explored = 1

	while not frontier.is_empty():
		steps += 1
		var phase := steps % _period
		var next := PackedInt64Array()
		for s in frontier:
			var parts := _split(s)
			var cell: Vector2i = _cells[parts[0]]
			var mask: int = parts[1]
			var all_on := (mask & act_full) == act_full   # activator bloccati, porte aperte
			for to in _destinations(cell, all_on, mask):
				# Il rinoceronte guarda la cella d'arrivo: turno nemici simulato per ogni mossa
				var turn := _advance_enemies(_decode_enemies(parts[2]), mask, steps, cell, to)
				var new_mask := _enter(to, steps, mask, all_on, turn[1], turn[2])
				if new_mask == DEAD:
					continue
				# Come in gioco: il controllo uscita avviene PRIMA che la tile cambi stato
				var reached_exit: bool = all_on and m.exit_cell != null and to == m.exit_cell
				var ns := _encode(_index[to], new_mask, phase, turn[0])
				if reached_exit or ((new_mask & act_full) == act_full and m.exit_cell == null):
					if not prev.has(ns):
						prev[ns] = s
					return {"steps": steps, "path": _path(prev, ns)}
				if prev.has(ns):
					continue
				prev[ns] = s
				next.append(ns)
				states_explored += 1
				if states_explored > MAX_STATES:
					return _fail("troppi stati esplorati (> %d)" % MAX_STATES)
		frontier = next
	return _fail("nessuna soluzione")

# ---------- Mosse del player ----------
## Celle raggiungibili con una mossa: passo normale o salto con la liana
func _destinations(cell: Vector2i, all_on: bool, mask: int) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for dir in LevelModel.DIRS:
		var to := cell + dir
		if _m.can_step(cell, to, all_on):
			out.append(to)
		if _m.has_vine:
			var v = _m.vine_target(cell, dir, all_on, mask)
			if v != null and not out.has(v):
				out.append(v)
	return out

## Maschera dopo essere entrati in `to`, DEAD se si muore.
## Ordine del gioco: colpi immediati -> check_tile -> check_pickup -> colpi a fine movimento
func _enter(to: Vector2i, step: int, mask: int, all_on: bool, hits_now: int, hits_late: int) -> int:
	var armor := (mask & _armor) != 0
	var shielded := false   # armatura appena rotta: invulnerabile per il resto del passo

	if hits_now > 0:
		if not armor:
			return DEAD
		armor = false
		shielded = true

	if _m.is_deadly(to, step, mask):
		if not _m.can_absorb(to):
			return DEAD   # vuoto: l'armatura non serve
		if not shielded:
			if not armor:
				return DEAD
			armor = false
			shielded = true

	var new_mask := mask
	if not all_on and _m.activator_bit.has(to):
		new_mask ^= 1 << _m.activator_bit[to]
	if _m.switch_key.has(to):
		new_mask |= _m.key_bit(_m.switch_key[to])
	if _m.wall_flag.has(to):
		new_mask |= _m.wall_flag[to]   # calpestato col piccone: rotto
	if _m.armor_pickups.has(to):
		armor = true

	if hits_late > 0 and not shielded:
		if not armor:
			return DEAD
		armor = false

	new_mask &= ~_armor
	if armor:
		new_mask |= _armor
	return new_mask

# ---------- Turno dei nemici (Scarab.take_turn) ----------
## Ritorna [codice_nemici, colpi_immediati, colpi_a_fine_movimento]
func _advance_enemies(list: Array, mask: int, step: int, from: Vector2i, to: Vector2i) -> Array:
	var hits_now := 0
	var hits_late := 0
	var pending := {}   # nemico -> danni presi in questo turno (muore dopo il flash)
	var dashes := []    # scatti da completare dopo il turno degli altri: [nemico, dir, celle]

	for i in list.size():
		var e: Array = list[i]
		if e[0] == 0:
			continue
		var old: Vector2i = e[1]
		var dir := _facing(i, e)

		# --- In carica: scatta (Scarab._dash) ---
		if e[3] > 0:
			var n: int = e[3]
			e[3] = 0
			if old == to:
				hits_now += 1
			# La prima cella avviene subito, le altre dopo il primo await
			var r := _dash(list, i, dir, 1, mask, step, to, pending)
			hits_late += r[1]
			if not r[2] and n > 1:
				dashes.append([i, dir, n - 1])
			continue

		# --- Rinoceronte che ti vede: inizia la carica, resta fermo ---
		if _m.enemies[i].dash > 0:
			var sight := _sight(list, i, dir, mask)
			if sight.has(to):
				e[3] = sight.size()
				continue

		# --- Passo normale (Scarab._move_step) ---
		var target := old
		var pattern: Array = _m.enemies[i].pattern
		if not pattern.is_empty():
			target = old + dir
			e[2] = (e[2] + 1) % pattern.size()   # il pattern avanza anche se bloccato
		var moved := target != old and _can_move(list, i, old, target, mask)
		if not moved:
			if old == to:
				hits_now += 1
			continue
		e[1] = target
		if target == to or (target == from and old == to):
			hits_late += 1
		if _m.is_deadly(target, step, mask):
			pending[i] = pending.get(i, 0) + 1

	for d in dashes:
		hits_late += _dash(list, d[0], d[1], d[2], mask, step, to, pending)[1]

	for i in pending:
		list[i][0] = maxi(0, list[i][0] - pending[i])
	return [_encode_enemies(list), hits_now, hits_late]

## Scatta fino a `max_cells` celle. Ritorna [celle fatte, colpi al player, interrotto]
func _dash(list: Array, i: int, dir: Vector2i, max_cells: int, mask: int, step: int, to: Vector2i, pending: Dictionary) -> Array:
	var e: Array = list[i]
	var done := 0
	var hits := 0
	while done < max_cells:
		var c: Vector2i = e[1] + dir
		if not _can_move(list, i, e[1], c, mask):
			return [done, hits, true]
		e[1] = c
		done += 1
		if c == to:
			hits += 1   # l'armatura può assorbire, lui prosegue
		if _m.is_deadly(c, step, mask):
			pending[i] = pending.get(i, 0) + 1
			if e[0] - pending[i] <= 0:
				return [done, hits, true]   # morto sulla spina (vedi fix in Scarab._dash)
	return [done, hits, false]

## Celle in linea davanti al nemico, finché attraversabili (Scarab._sight_cells)
func _sight(list: Array, i: int, dir: Vector2i, mask: int) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	if dir == Vector2i.ZERO:
		return out
	var prev: Vector2i = list[i][1]
	for k in _m.enemies[i].dash:
		var c := prev + dir
		if not _can_move(list, i, prev, c, mask):
			break
		out.append(c)
		prev = c
	return out

## Direzione del prossimo passo del pattern (ZERO = pausa)
func _facing(i: int, e: Array) -> Vector2i:
	var pattern: Array = _m.enemies[i].pattern
	if pattern.is_empty():
		return Vector2i.ZERO
	return pattern[e[2]]

func _can_move(list: Array, me: int, from: Vector2i, to: Vector2i, mask: int) -> bool:
	return _m.enemy_can_enter(from, to, mask) and not _occupied(list, me, to)

## Cella occupata da un altro nemico vivo (anche se sta morendo in questo turno)
func _occupied(list: Array, me: int, cell: Vector2i) -> bool:
	for j in list.size():
		if j != me and list[j][0] > 0 and list[j][1] == cell:
			return true
	return false

func _plen(i: int) -> int:
	return maxi(1, _m.enemies[i].pattern.size())

func _hp_max(i: int) -> int:
	return int(_m.enemies[i].hp)

func _crad(i: int) -> int:
	return int(_m.enemies[i].dash) + 1

# ---------- Codifica dello stato ----------
func _encode(cell_idx: int, mask: int, phase: int, ecode: int) -> int:
	return ((cell_idx * _flag_radix + mask) * _period + phase) * _enemy_total + ecode

## [indice_cella, maschera, codice_nemici]
@warning_ignore("integer_division")
func _split(code: int) -> Array:
	var ecode := code % _enemy_total
	var rest := code / _enemy_total
	rest = rest / _period
	return [rest / _flag_radix, rest % _flag_radix, ecode]

## Nemico = [vita, cella, indice_pattern, carica]
func _encode_enemies(list: Array) -> int:
	var code := 0
	var mult := 1
	for i in list.size():
		var e: Array = list[i]
		var v := 0
		if e[0] > 0:
			v = 1 + (((_index[e[1]] * _plen(i) + e[2]) * _hp_max(i) + (e[0] - 1)) * _crad(i) + e[3])
		code += v * mult
		mult *= _enemy_radix[i]
	return code

@warning_ignore("integer_division")
func _decode_enemies(code: int) -> Array:
	var out := []
	for i in _m.enemies.size():
		var r := _enemy_radix[i]
		var v := code % r
		code = code / r
		if v == 0:
			out.append([0, Vector2i.ZERO, 0, 0])
			continue
		v -= 1
		var charge := v % _crad(i)
		v = v / _crad(i)
		var hp := v % _hp_max(i) + 1
		v = v / _hp_max(i)
		var plen := _plen(i)
		out.append([hp, _cells[v / plen], v % plen, charge])
	return out

func _path(prev: Dictionary, s: int) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	while s != ROOT:
		out.push_front(_cells[_split(s)[0]])
		s = prev[s]
	return out

func _fail(reason: String) -> Dictionary:
	return {"steps": -1, "reason": reason}

# ---------- Utility ----------
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
