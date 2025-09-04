# PlayerInteraction.gd
extends Resource
class_name PlayerInteraction

const DeathType = preload("res://Scripts/Player/DeathType.gd").DeathType

var player: Node2D
var tile_layer: Node2D
var pickup_layer: Node2D

func setup(player_ref: Node2D, tile_layer_ref: Node2D, pickup_layer_ref: Node2D) -> void:
	player = player_ref
	tile_layer = tile_layer_ref
	pickup_layer = pickup_layer_ref

func check_tile():
	var tile = _get_tile_under_player()
	if tile and tile.has_method("on_player_enter"):
		tile.on_player_enter()
	else:
		print("[DEBUG] Player fuori mappa!")
		player.on_player_died(DeathType.VOID)

func check_pickup():
	var pickup  = _get_pickup_under_player()
	if pickup and pickup.has_method("on_player_enter"):
		pickup.on_player_enter(player)

func _get_tile_under_player() -> TileBase:
	var player_pos = player.global_position
	for child in tile_layer.get_children():
		if child is TileBase:
			var tile_pos = child.global_position
			if is_point_on_iso_tile(tile_pos, player_pos):
				print("[DEBUG] Player sopra tile:", child.name)
				return child
	return null

func _get_pickup_under_player() -> PickupBase:
	var player_pos = player.global_position
	for child in pickup_layer.get_children():
		if child is PickupBase and child.is_active:
			var tile_pos = child.global_position
			if is_point_on_iso_tile(tile_pos, player_pos):
				print("[DEBUG] Player sopra pickup:", child.name)
				return child
	return null

func is_point_on_iso_tile(tile_pos: Vector2, point: Vector2) -> bool:
	var local = point - tile_pos
	return abs(local.x / 2) + abs(local.y) <= 16
