extends RefCounted
class_name Pathfinder

# Direzioni valide (4-way grid)
# Devono corrispondere ai tuoi DIRECTION_BITS del player
const DIRS := [
	Vector2i(1, 0),
	Vector2i(-1, 0),
	Vector2i(0, 1),
	Vector2i(0, -1)
]

var movement_map: TileMapLayer
var visual_map: TileMapLayer
var DIRECTION_BITS: Dictionary

func _init(_movement_map: TileMapLayer, _visual_map: TileMapLayer, _direction_bits: Dictionary):
	movement_map = _movement_map
	visual_map = _visual_map
	DIRECTION_BITS = _direction_bits

# --------------------------------------------------
# Punto di ingresso → restituisce LA PROSSIMA TILE
# --------------------------------------------------
func get_next_step(start: Vector2i, goal: Vector2i) -> Vector2i:
	if start == goal:
		return start

	var path := a_star(start, goal)

	if path.size() >= 2:
		return path[1]	# path[0] = start, path[1] = next step
	else:
		return start	# Nessun percorso → resta fermo


# --------------------------------------------------
# Implementazione A*
# --------------------------------------------------
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

		for dir in DIRS:
			var neighbor = current + dir

			if closed.has(neighbor):
				continue

			if not can_move(current, neighbor):
				continue

			var tile_cost = get_tile_cost(neighbor)
			var tentative_g = current_data["g"] + tile_cost

			if not open.has(neighbor) or tentative_g < open[neighbor]["g"]:
				came_from[neighbor] = current
				open[neighbor] = {
					"g": tentative_g,
					"f": tentative_g + heuristic(neighbor, goal)
				}

	return []  # Nessun percorso trovato


# --------------------------------------------------
# Movement mask check (identico al player)
# --------------------------------------------------
func can_move(from: Vector2i, to: Vector2i) -> bool:
	
	if movement_map == null:
		push_error("movement_map is null in Pathfinder, check initialization!")
		return false
	
	var tile_data := movement_map.get_cell_tile_data(from)
	if tile_data == null:
		return false

	var mask = tile_data.get_custom_data("MovementMask")
	if mask == null:
		return true	# nessuna restrizione → libero

	var dir := to - from
	var bit = DIRECTION_BITS.get(dir, 0)

	# Se il bit è presente → quella direzione è BLOCCATA
	return (mask & bit) == 0


# --------------------------------------------------
# Funzioni di supporto per A*
# --------------------------------------------------
func get_tile_cost(pos: Vector2i) -> int:
	if visual_map == null:
		return 999
	
	var tile_instance = get_tile_instance_at(pos)
	
	if tile_instance == null:
		return 999
	
	if "peso" in tile_instance:
		return tile_instance.peso
	else:
		return 1

func get_tile_instance_at(pos: Vector2i) -> TileBase:
	if visual_map == null:
		return null

	var world_pos = visual_map.map_to_local(pos) + visual_map.global_position
	for child in visual_map.get_children():
		if child is TileBase:
			if child.global_position.distance_to(world_pos) < 1.0:
				return child
	return null

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
