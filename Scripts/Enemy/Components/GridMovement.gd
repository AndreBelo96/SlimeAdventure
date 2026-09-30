# Scripts/Enemy/GridMovement.gd
class_name GridMovement
extends Resource

var enemy: Node2D
var tilemap: TileMapLayer
var center_offset: Vector2
var grid_position: Vector2i
var pathfinder: Pathfinder

func setup(_enemy: Node2D, _tilemap: TileMapLayer, _center_offset: Vector2, start_pos: Vector2i, movement_map: TileMapLayer = null, visual_map: TileMapLayer = null) -> void:
	enemy = _enemy
	tilemap = _tilemap
	center_offset = _center_offset

	if movement_map and visual_map:
		pathfinder = Pathfinder.new(movement_map, visual_map, GridUtils.DIRECTION_BITS)

	snap_to(start_pos)

func snap_to(coords: Vector2i) -> void:
	grid_position = coords
	GridUtils.snap_to_tile_center(enemy, tilemap, coords, center_offset)

func move_to(next_tile: Vector2i, duration: float = 0.2) -> void:
	var target_pos: Vector2 = tilemap.map_to_local(next_tile) - center_offset
	var tween := enemy.create_tween()
	tween.tween_property(enemy, "global_position", target_pos, duration)
	await tween.finished
	snap_to(next_tile)

func get_next_step(target: Vector2i) -> Vector2i:
	if pathfinder == null:
		push_error("GridMovement: pathfinder non inizializzato (movement_map/visual_map mancanti)")
		return grid_position
	return pathfinder.get_next_step(grid_position, target)

func is_adjacent_to(target: Vector2i, diagonal: bool = true) -> bool:
	if diagonal:
		return GridUtils.is_adjacent_8(grid_position, target)
	return GridUtils.is_adjacent_4(grid_position, target)
