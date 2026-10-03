@tool
extends RefCounted
class_name LevelModel
## Il livello come dati puri (niente nodi): usabile nell'editor e a runtime.

enum Cell { FLOOR, ACTIVATOR, SPIKE, SPIKE_STEP, SPIKE_SWITCH, SWITCH, WALL, BLOCK, ANCHOR }

const DIRS: Array[Vector2i] = [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]
const DIR_BITS := {Vector2i(0, -1): 1, Vector2i(1, 0): 2, Vector2i(0, 1): 4, Vector2i(-1, 0): 8}

const SPIKE_STEP_PERIOD := 3   # = TileSpikeStep.STEPS_TO_TRIGGER
const VINE_RANGE := 2          # = PlayerMovement.VINE_RANGE
## Default di TileSwitch/TileSpikeSwitch quando la cella non ha dati nel LogicMapLayer
const DEFAULT_KEY := "A"
const DEFAULT_ACTION := "deactivate"

## Scena della tile -> tipo. Le scene non in elenco rendono il livello "non supportato".
const TILE_TYPES := {
	"TileNormal": Cell.FLOOR,
	"TileVineAnchor": Cell.ANCHOR,
	"TileActivator": Cell.ACTIVATOR,
	"TileSpike": Cell.SPIKE,
	"TileSpikeStep": Cell.SPIKE_STEP,
	"TileSpikeSwitch": Cell.SPIKE_SWITCH,
	"TileSwitch": Cell.SWITCH,
	"TileWall": Cell.WALL,
	"TileMushroom": Cell.BLOCK,
}

var cells := {}             # Vector2i -> Cell (solo celle con una tile)
var masks := {}             # Vector2i -> MovementMask
var activators: Array[Vector2i] = []
var activator_bit := {}     # Vector2i -> indice del bit
var doors := {}             # Vector2i -> true
var npcs := {}              # Vector2i -> true
var armor_pickups := {}     # Vector2i -> true (solo pickup con respawn)
var start := Vector2i.ZERO
var exit_cell = null        # Vector2i, oppure null se il livello non ha uscita
var has_pickaxe := false
var has_vine := false
var period := 1             # ciclo temporale del livello (1 = statico)
var unsupported: Array[String] = []

## Switch: ogni chiave premuta è un bit dello stato, sopra quelli degli activator
var keys: Array[String] = []
var switch_key := {}         # cella dello switch -> indice chiave
var spike_key := {}          # cella della spina a switch -> indice chiave
var spike_starts_down := {}  # spine a switch che partono abbassate (azione "activate")

static func from_scene(root: Node, pickaxe := false, vine := false) -> LevelModel:
	var m := LevelModel.new()
	m.has_pickaxe = pickaxe
	m.has_vine = vine
	var tiles: TileMapLayer = root.get_node("TileMapLayer")
	var movement: TileMapLayer = root.get_node("MovementLogicMapLayer")
	var logic: TileMapLayer = root.get_node("LogicMapLayer")
	var ysort: Node2D = root.get_node("YSort")
	var player: Node2D = ysort.get_node("Player")

	# LogicMapLayer: uscita + chiave/azione di switch e spine
	var logic_data := {}   # cella -> [chiave, azione]
	for cell in logic.get_used_cells():
		var data := logic.get_cell_tile_data(cell)
		if data == null:
			continue
		var key = data.get_custom_data("key")
		if key == "EXIT":
			m.exit_cell = cell
		else:
			logic_data[cell] = [key, data.get_custom_data("action")]

	for cell in tiles.get_used_cells():
		var tile_name := _scene_name(tiles, cell)
		if not TILE_TYPES.has(tile_name):
			m._unsupported(tile_name)
			continue
		var type: Cell = TILE_TYPES[tile_name]
		m.cells[cell] = type
		match type:
			Cell.ACTIVATOR:
				m.activator_bit[cell] = m.activators.size()
				m.activators.append(cell)
			Cell.SPIKE_STEP:
				m.period = SPIKE_STEP_PERIOD
			Cell.SWITCH, Cell.SPIKE_SWITCH:
				var info: Array = logic_data.get(cell, [DEFAULT_KEY, DEFAULT_ACTION])
				var k := m._key_index(info[0])
				if type == Cell.SWITCH:
					if info[1] == "activate" or info[1] == "deactivate":
						m.switch_key[cell] = k   # senza azione lo switch non fa nulla
				else:
					m.spike_key[cell] = k
					if info[1] == "activate":
						m.spike_starts_down[cell] = true

	for cell in movement.get_used_cells():
		var data := movement.get_cell_tile_data(cell)
		if data and data.get_custom_data("MovementMask"):
			m.masks[cell] = int(data.get_custom_data("MovementMask"))

	for cell in ysort.get_node("DoorsMapLayer").get_used_cells():
		m.doors[cell] = true
	for cell in ysort.get_node("NPCMapLayer").get_used_cells():
		m.npcs[cell] = true

	var pickups: TileMapLayer = ysort.get_node("PickupMapLayer")
	for cell in pickups.get_used_cells():
		var scene := _scene_at(pickups, cell)
		if scene == null or not "Armor" in scene.resource_path.get_file():
			continue
		if _root_property(scene, "respawn", true):
			m.armor_pickups[cell] = true
		else:
			m._unsupported("PickupArmor senza respawn")
	_find_enemies(root, m)

	# Fuori dall'albero non esiste global_position: si sommano le posizioni locali
	m.start = tiles.local_to_map(player.position + ysort.position - tiles.position)
	return m

## Bit totali dello stato: activator + chiavi + armatura
func state_bits() -> int:
	return activators.size() + keys.size() + (1 if not armor_pickups.is_empty() else 0)

## Bit di una chiave nello stato (sopra i bit degli activator)
func key_bit(key_idx: int) -> int:
	return 1 << (activators.size() + key_idx)

## Bit dell'armatura (sopra le chiavi). Mai acceso se il livello non ha pickup armatura.
func armor_bit() -> int:
	return 1 << (activators.size() + keys.size())

## Si può entrare nella cella? (altrimenti rimbalzo, nessun passo)
func can_step(from: Vector2i, to: Vector2i, all_on: bool) -> bool:
	if (masks.get(from, 0) & DIR_BITS.get(to - from, 0)) != 0:
		return false
	if npcs.has(to) or (doors.has(to) and not all_on):
		return false
	var c = cells.get(to, -1)
	if c == Cell.BLOCK or (c == Cell.WALL and not has_pickaxe):
		return false
	return true

## Entrarci al passo `step`, con le chiavi in `mask`, uccide?
func is_deadly(cell: Vector2i, step: int, mask: int) -> bool:
	if not cells.has(cell):
		return true
	match cells[cell]:
		Cell.SPIKE:
			return true
		Cell.SPIKE_STEP:
			return step > 0 and step % SPIKE_STEP_PERIOD == 0
		Cell.SPIKE_SWITCH:
			if spike_starts_down.has(cell):
				return false   # alzata solo fino al passo dopo: mai mortale per il player
			return (mask & key_bit(spike_key[cell])) == 0
	return false

## Una morte su questa cella è assorbibile dall'armatura? (spine sì, vuoto no)
func can_absorb(cell: Vector2i) -> bool:
	return cells.has(cell)

## Cella d'arrivo della liana in direzione `dir`, oppure null. Come PlayerMovement.find_vine_target.
## Sassi sempre considerati intatti (bloccanti): approssimazione conservativa.
func vine_target(from: Vector2i, dir: Vector2i, all_on: bool):
	var prev := from
	for dist in range(1, VINE_RANGE + 1):
		var cell := from + dir * dist
		if (masks.get(prev, 0) & DIR_BITS[dir]) != 0:
			return null
		if npcs.has(cell) or (doors.has(cell) and not all_on):
			return null
		var c = cells.get(cell, -1)
		if c == Cell.ANCHOR:
			return cell
		if c == Cell.WALL or c == Cell.BLOCK:
			return null
		prev = cell   # vuoto e spine si sorvolano
	return null

func _key_index(key: String) -> int:
	var i := keys.find(key)
	if i == -1:
		keys.append(key)
		i = keys.size() - 1
	return i

func _unsupported(what: String) -> void:
	if not unsupported.has(what):
		unsupported.append(what)

static func _scene_at(layer: TileMapLayer, cell: Vector2i) -> PackedScene:
	var src = layer.tile_set.get_source(layer.get_cell_source_id(cell))
	if src is TileSetScenesCollectionSource:
		return src.get_scene_tile_scene(layer.get_cell_alternative_tile(cell))
	return null

static func _scene_name(layer: TileMapLayer, cell: Vector2i) -> String:
	var scene := _scene_at(layer, cell)
	return scene.resource_path.get_file().get_basename() if scene else "?"

## Legge una proprietà del nodo radice dalla scena senza istanziarla
static func _root_property(scene: PackedScene, prop: String, default_value):
	var state := scene.get_state()
	for i in state.get_node_property_count(0):
		if state.get_node_property_name(0, i) == prop:
			return state.get_node_property_value(0, i)
	return default_value

static func _find_enemies(node: Node, m: LevelModel) -> void:
	for child in node.get_children():
		if "/Enemy/" in child.scene_file_path:
			m._unsupported("nemico " + child.name)
		_find_enemies(child, m)
