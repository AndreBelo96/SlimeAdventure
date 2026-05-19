# GridUtils.gd — autoload
extends Node

const DIRECTION_BITS := {
	Vector2i(0, -1): 1,
	Vector2i(1, 0): 2,
	Vector2i(0, 1): 4,
	Vector2i(-1, 0): 8,
}

func snap_to_tile_center(node: Node2D, tilemap: TileMapLayer, coords: Vector2i, center_offset: Vector2 = Vector2.ZERO) -> void:
	var tile_pos = tilemap.map_to_local(coords)
	node.global_position = tile_pos - center_offset

func get_tile_center_global(tilemap: TileMapLayer, coords: Vector2i) -> Vector2:
	return tilemap.to_global(tilemap.map_to_local(coords))

# Solo le 4 direzioni cardinali (N/S/E/W)
func is_adjacent_4(a: Vector2i, b: Vector2i) -> bool:
	var dx = abs(a.x - b.x)
	var dy = abs(a.y - b.y)
	return (dx == 1 and dy == 0) or (dx == 0 and dy == 1)

# Tutte le 8 direzioni incluse le diagonali
func is_adjacent_8(a: Vector2i, b: Vector2i) -> bool:
	var dx = abs(a.x - b.x)
	var dy = abs(a.y - b.y)
	return dx <= 1 and dy <= 1 and not (dx == 0 and dy == 0)

func coords_from_global(tilemap: TileMapLayer, global_pos: Vector2) -> Vector2i:
	return tilemap.local_to_map(tilemap.to_local(global_pos))
