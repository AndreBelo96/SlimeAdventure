extends RefCounted
class_name Pathfinder

var movement_map: TileMapLayer
var _tile_index: GridSpatialIndex

func _init(_movement_map: TileMapLayer, visual_map: TileMapLayer) -> void:
	movement_map = _movement_map
	_tile_index = GridSpatialIndex.new(visual_map)

func get_next_step(start: Vector2i, goal: Vector2i) -> Vector2i:
	if start == goal:
		return start
	var path := a_star(start, goal)
	return path[1] if path.size() >= 2 else start

func a_star(start: Vector2i, goal: Vector2i) -> Array:
	var open := {}
	var closed := {}
	var came_from := {}
	open[start] = {"g": 0, "f": heuristic(start, goal)}

	while open.size() > 0:
		var current: Vector2i = get_lowest_f(open)
		var current_data = open[current]
		if current == goal:
			return reconstruct_path(came_from, current)

		closed[current] = true
		open.erase(current)

		for dir in GridUtils.DIRECTION_BITS:
			var neighbor: Vector2i = current + dir
			if closed.has(neighbor) or not can_move(current, neighbor):
				continue
			var tentative_g = current_data["g"] + get_tile_cost(neighbor)
			if not open.has(neighbor) or tentative_g < open[neighbor]["g"]:
				came_from[neighbor] = current
				open[neighbor] = {"g": tentative_g, "f": tentative_g + heuristic(neighbor, goal)}

	push_warning("A*: nessun percorso da ", start, " a ", goal)
	return []

func can_move(from: Vector2i, to: Vector2i) -> bool:
	if not GridUtils.mask_allows(movement_map, from, to):
		return false
	var tile := _tile_index.get_tile_at(to)
	return tile != null and not tile.is_blocking()

func get_tile_cost(pos: Vector2i) -> int:
	var tile := _tile_index.get_tile_at(pos)
	return tile.weight if tile else TileBase.BLOCKED_WEIGHT

func invalidate_tile_cache() -> void:
	_tile_index.invalidate()

func heuristic(a: Vector2i, b: Vector2i) -> int:
	return abs(a.x - b.x) + abs(a.y - b.y)

func get_lowest_f(open: Dictionary) -> Vector2i:
	var best = open.keys()[0]
	var best_f = open[best]["f"]
	for k in open.keys():
		if open[k]["f"] < best_f:
			best_f = open[k]["f"]
			best = k
	return best

func reconstruct_path(came_from: Dictionary, current: Vector2i) -> Array:
	var path := [current]
	while came_from.has(current):
		current = came_from[current]
		path.insert(0, current)
	return path
