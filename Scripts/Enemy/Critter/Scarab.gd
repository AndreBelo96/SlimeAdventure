# Scripts/Enemy/Scarab.gd
extends EnemyBase
class_name Scarab

@export var pattern: Array[Vector2i] = []
@export var move_duration := 0.15
@export var use_start_cell := true
@export var start_cell := Vector2i.ZERO
@export var warning_color := Color(0.801, 0.0, 0.039, 0.627)
@export var max_health := 1

@export_group("Dash")
@export var can_dash := false
@export var dash_sight := 3
@export var dash_step_duration := 0.07
@export var dash_warning_color := Color(0.801, 0.0, 0.039, 0.627)
@export var sight_warning_color := Color(0.734, 0.813, 0.007, 0.3)

var _charging := false
var _charge_cells: Array[Vector2i] = []
var _level_logic
var _visual_map: TileMapLayer
var _tile_index: TileSpatialIndex
var _warnings: WarningPainter

func _ready():
	super._ready()
	setup_health(max_health)

	var patrol := PatrolBehavior.new()
	patrol.directions = pattern
	turn_behavior = patrol

	_level_logic = get_tree().get_first_node_in_group("level_logic")
	if _level_logic.movement_map == null:
		push_error("Scarab: LevelLogic.movement_map non assegnato (collega MovementLogicMapLayer in BaseLevel.tscn)")
	_visual_map = _level_logic.tile_layer as TileMapLayer
	_tile_index = TileSpatialIndex.new(_visual_map)
	_warnings = WarningPainter.new(self, _tile_index)

	var start := start_cell if use_start_cell else _visual_map.local_to_map(_visual_map.to_local($Center.global_position))
	setup_grid(_visual_map, $Center.position, start)
	animation.play("IDLE")

	await get_tree().process_frame
	_tile_index.invalidate()
	_update_warnings()

# ---------- Turno ----------
func take_turn():
	if is_dead():
		return
	if _charging:
		await _dash()
	elif _player_in_sight():
		_start_charge()
	else:
		await _move_step()
	if not is_dead():
		_update_warnings()

func _player_in_sight() -> bool:
	var player = PlayerRef.player
	return player != null and _sight_cells().has(player.grid_position)

# ---------- Carica ----------
func _start_charge() -> void:
	_hit_player_on_my_cell()
	_charging = true
	_charge_cells = _sight_cells()
	_face_towards(_charge_cells[0])
	VisualEffects.flash(animation, 0.25, Color(2.0, 0.6, 0.6))   # PLACEHOLDER

func _dash() -> void:
	_charging = false
	_warnings.clear()
	_hit_player_on_my_cell()
	var player = PlayerRef.player
	if player:
		player.lock_input()

	animation.play("WALK")
	for cell in _charge_cells:
		if not _can_step(grid_position, cell):
			break
		grid_position = cell
		grid_movement.grid_position = cell
		await grid_movement.move_to(cell, dash_step_duration)
		if player and cell == player.grid_position:
			player.on_player_died(DeathType.Type.ENEMY)   # l'armatura può assorbire, lui prosegue
		_level_logic.enemy_turn_handler.apply_tile_effect(self)
		if is_dead():
			break
	_charge_cells.clear()

	if not is_dead():
		animation.play("IDLE")
	if player:
		player.unlock_input()

## Se il player è entrato nella sua cella mentre era fermo a caricare.
func _hit_player_on_my_cell() -> void:
	var player = PlayerRef.player
	if player and player.grid_position == grid_position:
		player.on_player_died(DeathType.Type.ENEMY)

## Direzione del prossimo passo del pattern; ZERO se è una pausa.
func _get_facing() -> Vector2i:
	return (turn_behavior as PatrolBehavior).peek_next_tile(self) - grid_position

## Celle in linea davanti, finché attraversabili (max dash_sight).
func _sight_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	var dir := _get_facing()
	if not can_dash or dir == Vector2i.ZERO:
		return cells
	var prev := grid_position
	for i in dash_sight:
		var cell := prev + dir
		if not _can_step(prev, cell):
			break
		cells.append(cell)
		prev = cell
	return cells

# ---------- Passo normale ----------
func _move_step() -> void:
	var old_cell := grid_position
	var next_tile := turn_behavior.get_next_tile(self)
	var moves := next_tile != old_cell and _can_step(old_cell, next_tile)
	if not moves:
		next_tile = old_cell

	var player = PlayerRef.player
	var hits_player := false
	if player:
		var p_now: Vector2i = player.grid_position
		var p_prev: Vector2i = player.previous_grid_position
		var lands_on_player := next_tile == p_now
		var crossing := moves and next_tile == p_prev and old_cell == p_now
		hits_player = lands_on_player or crossing

	if not moves:
		if hits_player:
			player.on_player_died(DeathType.Type.ENEMY)
		return

	if hits_player:
		player.lock_input()

	_face_towards(next_tile)
	grid_position = next_tile
	grid_movement.grid_position = next_tile

	animation.play("WALK")
	await grid_movement.move_to(next_tile, move_duration)
	animation.play("IDLE")

	if hits_player:
		player.on_player_died(DeathType.Type.ENEMY)
		player.unlock_input()

	_level_logic.enemy_turn_handler.apply_tile_effect(self)

# ---------- Warning ----------
func _update_warnings() -> void:
	_warnings.clear()
	if _charging:
		for cell in _charge_cells:
			_warnings.paint(cell, dash_warning_color, TileWarning.Priority.CHARGE)
		return

	var next := (turn_behavior as PatrolBehavior).peek_next_tile(self)
	var walks := next != grid_position and _can_step(grid_position, next)
	if walks:
		_warnings.paint(next, warning_color, TileWarning.Priority.STEP)
	for cell in _sight_cells():
		if not (walks and cell == next):
			_warnings.paint(cell, sight_warning_color, TileWarning.Priority.SIGHT)

# ---------- Movimento ----------
func _can_step(from: Vector2i, to: Vector2i) -> bool:
	if not _mask_allows(from, to):
		return false
	var tile := _tile_index.get_tile_at(to)
	if tile == null or tile.weight >= 999 or not tile.can_enter():
		return false   # vuoto, muro, fungo, sasso
	for other in get_tree().get_nodes_in_group("enemy"):
		if other != self and not other.is_dead() and other.grid_position == to:
			return false
	return true

# Stessa logica del player: nessun dato nella maschera = libero
func _mask_allows(from: Vector2i, to: Vector2i) -> bool:
	var data: TileData = _level_logic.movement_map.get_cell_tile_data(from)
	if data == null:
		return true
	var mask = data.get_custom_data("MovementMask")
	if mask == null:
		return true
	return (mask & GridUtils.DIRECTION_BITS.get(to - from, 0)) == 0

func _face_towards(cell: Vector2i) -> void:
	var screen_dir := _visual_map.map_to_local(cell) - _visual_map.map_to_local(grid_position)
	if screen_dir.x != 0:
		animation.flip_h = screen_dir.x < 0   # assume sprite disegnato verso destra

func damage_animation():
	await VisualEffects.flash(animation)

func die():
	if is_dead():
		return
	_warnings.clear()
	super.die()
	await animation.animation_finished
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	await tween.finished
	queue_free()
