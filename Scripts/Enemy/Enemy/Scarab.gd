# Scripts/Enemy/Scarab.gd
extends EnemyBase
class_name Scarab

const WARNING_SCENE := preload("res://Scenes/Decorations/Warning/WarningTile.tscn")

@export var pattern: Array[Vector2i] = []
@export var move_duration := 0.15
@export var use_start_cell := true
@export var start_cell := Vector2i.ZERO
@export var warning_color := Color(1.0, 0.6, 0.0, 0.4)
@export var max_health := 1

@export_group("Dash")
@export var can_dash := true
@export var dash_sight := 2
@export var dash_step_duration := 0.07
@export var dash_warning_color := Color(1.0, 0.1, 0.1, 0.4)

var _level_logic
var _visual_map: TileMapLayer
var _tile_index: TileSpatialIndex
var _warnings: Array[Node2D] = []

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
	var distance := _player_distance_in_sight()
	if distance > 0:
		await _dash(distance)
	else:
		await _move_step()
	if not is_dead():
		_update_warnings()

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

## 1..dash_sight se il player è nella linea di vista, 0 altrimenti.
func _player_distance_in_sight() -> int:
	var player = PlayerRef.player
	if player == null:
		return 0
	return _sight_cells().find(player.grid_position) + 1

# ---------- Scatto ----------
func _dash(distance: int) -> void:
	var dir := _get_facing()
	var player = PlayerRef.player
	_clear_warnings()
	_face_towards(grid_position + dir)
	if player:
		player.lock_input()

	animation.play("WALK")
	# fino alla cella subito oltre il player, fermandosi prima se bloccato
	for i in distance + 1:
		var next := grid_position + dir
		if not _can_step(grid_position, next):
			break
		grid_position = next
		grid_movement.grid_position = next
		await grid_movement.move_to(next, dash_step_duration)
		if player and next == player.grid_position:
			player.on_player_died(DeathType.Type.ENEMY)   # l'armatura può assorbire, lui prosegue
		_level_logic.enemy_turn_handler.apply_tile_effect(self)
		if is_dead():
			break

	if not is_dead():
		animation.play("IDLE")
	if player:
		player.unlock_input()

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
	_clear_warnings()
	if can_dash:
		for cell in _sight_cells():
			_add_warning(cell, dash_warning_color)
		return
	var next := (turn_behavior as PatrolBehavior).peek_next_tile(self)
	if next != grid_position and _can_step(grid_position, next):
		_add_warning(next, warning_color)

func _add_warning(cell: Vector2i, color: Color) -> void:
	var w: Node2D = WARNING_SCENE.instantiate()
	get_parent().add_child(w)          # nello YSort, MAI nel TileMapLayer
	w.get_node("Sprite2D").modulate = color
	w.global_position = _visual_map.to_global(_visual_map.map_to_local(cell))
	_warnings.append(w)

func _clear_warnings() -> void:
	for w in _warnings:
		if is_instance_valid(w):
			w.queue_free()
	_warnings.clear()

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
	_clear_warnings()
	super.die()
	await animation.animation_finished
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	await tween.finished
	queue_free()
