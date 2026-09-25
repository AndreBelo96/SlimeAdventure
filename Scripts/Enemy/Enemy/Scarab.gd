# Scripts/Enemy/Scarab.gd
extends EnemyBase
class_name Scarab

const WARNING_SCENE := preload("res://Scenes/Decorations/Warning/WarningTile.tscn")
var _warning: Node2D

@export var pattern: Array[Vector2i] = []
@export var move_duration := 0.15
@export var use_start_cell := true
@export var start_cell := Vector2i.ZERO
@export var warning_color := Color(1.0, 0.6, 0.0, 0.4)

var _level_logic
var _visual_map: TileMapLayer
var _tile_index: TileSpatialIndex

func _ready():
	super._ready()
	setup_health(1)
	
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
	_update_warning()

func take_turn():
	if is_dead():
		return
	await _move_step()
	if not is_dead():
		_update_warning()

func _move_step() -> void:
	var old_cell := grid_position
	var next_tile := turn_behavior.get_next_tile(self)
	var moves := next_tile != old_cell and _can_enter(next_tile)
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

func _update_warning() -> void:
	var next := (turn_behavior as PatrolBehavior).peek_next_tile(self)
	var show := next != grid_position and _can_enter(next)

	if show and _warning == null:
		_warning = WARNING_SCENE.instantiate()
		get_parent().add_child(_warning)          # nello YSort, MAI nel TileMapLayer
		_warning.get_node("Sprite2D").modulate = warning_color

	if _warning:
		_warning.visible = show
		if show:
			_warning.global_position = _visual_map.to_global(_visual_map.map_to_local(next))

func _can_enter(cell: Vector2i) -> bool:
	if not _mask_allows(grid_position, cell):
		return false
	var tile := _tile_index.get_tile_at(cell)
	if tile == null or tile.weight >= 999 or not tile.can_enter():
		return false   # vuoto, muro, fungo, sasso
	for other in get_tree().get_nodes_in_group("enemy"):
		if other != self and not other.is_dead() and other.grid_position == cell:
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

func die():
	if is_dead():
		return
	if _warning:
		_warning.queue_free()
		_warning = null
	super.die()
	await animation.animation_finished
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	await tween.finished
	queue_free()
