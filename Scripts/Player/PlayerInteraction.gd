# PlayerInteraction.gd
extends Resource
class_name PlayerInteraction

const DeathType = preload("res://Scripts/Player/DeathType.gd").DeathType

var player: Node2D
var tile_layer: Node2D

func setup(player_ref: Node2D, tile_layer_ref: Node2D) -> void:
	player = player_ref
	tile_layer = tile_layer_ref
	call_deferred("_connect_all_tiles")

func _connect_all_tiles() -> void:
	for child in tile_layer.get_children():
		if child is TileBase:
			if not child.is_connected("tile_triggered", Callable(self, "_on_tile_triggered")):
				child.connect("tile_triggered", Callable(self, "_on_tile_triggered"))

func check_tile():
	var tile = _get_tile_under_player()
	if tile and tile.has_method("on_player_enter"):
		tile.on_player_enter()

func _get_tile_under_player() -> TileBase:
	var player_pos = player.global_position
	for child in tile_layer.get_children():
		if child is TileBase:
			var tile_pos = child.global_position
			if is_point_on_iso_tile(tile_pos, player_pos):
				print("[DEBUG] Player sopra tile:", child.name)
				return child
	return null

func is_point_on_iso_tile(tile_pos: Vector2, point: Vector2) -> bool:
	var local = point - tile_pos
	return abs(local.x / 2) + abs(local.y) <= 16

func _on_tile_triggered(tile: TileBase, action: String, data: Dictionary) -> void:
	print("[PlayerInteraction] Segnale ricevuto da", tile.name, "azione:", action, "dati:", data)
	match action:
		"death":
			player.on_player_died(data.get("death_type", 0))
		"activate":
			tile.is_active = data.get("is_active", true)
			print("[PlayerInteraction] Tile attivata:", tile.name, "stato:", tile.is_active)
			check_victory()
		_:
			pass

func check_victory() -> void:
	for child in tile_layer.get_children():
		if child.has_method("is_activated") and not child.is_activated():
			return
	player.on_player_won()
