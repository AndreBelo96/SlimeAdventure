# PlayerInteraction.gd
extends Resource
class_name PlayerInteraction

const DEATH = DeathType.Type
#const TILE_HALF_SIZE = 16

var player: Node2D
var tile_layer: Node2D
var pickup_layer: Node2D
var _tile_index: GridSpatialIndex


func setup(player_ref: Node2D, tile_layer_ref: Node2D, pickup_layer_ref: Node2D) -> void:
	player = player_ref
	tile_layer = tile_layer_ref
	pickup_layer = pickup_layer_ref
	_tile_index = GridSpatialIndex.new(tile_layer)

func check_tile():
	var tile = _get_tile_under_player()
	if tile and tile.has_method("on_player_enter"):
		tile.on_player_enter()
	else:
		GameLogger.warn("Morte: tipo=VOID tile= no tile pos= " + str(player.global_position))
		player.on_player_died(DEATH.VOID)

func check_pickup():
	var pickup  = _get_pickup_under_player()
	if pickup and pickup.has_method("on_player_enter"):
		pickup.on_player_enter(player)

func _get_tile_under_player() -> TileBase:
	return _tile_index.get_at(player.grid_position) as TileBase

func _get_pickup_under_player() -> PickupBase:
	for child in pickup_layer.get_children():
		if child is PickupBase and child.is_active:
			var tile_coord = child.grid_position
			if have_same_coord(player.grid_position , tile_coord):
				GameLogger.info("Pickup -> Player sopra= " + str(child.name))
				return child
	return null

func have_same_coord(player_tile_coord: Vector2, pickup_tile_coord: Vector2):
	return player_tile_coord == pickup_tile_coord

#func is_point_on_iso_tile(tile_pos: Vector2, point: Vector2) -> bool:
	#var local = point - tile_pos
	#return abs(local.x / 2) + abs(local.y) <= TILE_HALF_SIZE
