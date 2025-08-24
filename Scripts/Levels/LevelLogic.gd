# -- LevelLogic.gd -- #
extends Node

@export var player: Node2D
@export var tile_layer: Node2D

func _ready():
	call_deferred("_connect_all_tiles")
	call_deferred("_connect_player_signal")

func _connect_all_tiles() -> void:
	for child in tile_layer.get_children():
		if child is TileBase:
			if not child.is_connected("tile_triggered", Callable(self, "_on_tile_triggered")):
				child.connect("tile_triggered", Callable(self, "_on_tile_triggered"))

func _connect_player_signal():
	var level_manager = get_parent()
	if level_manager:
		level_manager.connect("signal_victory", Callable(self, "check_victory"))

func _on_tile_triggered(tile: TileBase, action: String, data: Dictionary) -> void:
	print("[PlayerInteraction] Segnale ricevuto da", tile.name, "azione:", action, "dati:", data)
	match action:
		"death":
			player.on_player_died(data.get("death_type", 0))
		"activate":
			tile.is_active = data.get("is_active", true)
			print("[PlayerInteraction] Tile attivata:", tile.name, "stato:", tile.is_active)
		"switch":
			var chiave = data.get("chiave", "")
			_unlock_spikes(chiave)
		_:
			pass

func _unlock_spikes(chiave: String):
	for child in tile_layer.get_children():
		if child.is_in_group("spine") and child.chiave == chiave:
			child.disattiva()

func check_victory():
	for child in tile_layer.get_children():
		if child.has_method("is_activated") and not child.is_activated():
			return
	
	var level_manager = get_parent()
	if player is not Node2D or not level_manager or level_manager.exit_position == Vector2.ZERO:
		return
		
	var player_tile = get_coords_from_global_position(player.position)
	var exit_tile = Vector2i(level_manager.exit_position)
	
	if  player_tile == exit_tile:
		player.on_player_won()

func get_coords_from_global_position(global_pos: Vector2) -> Vector2i:
	return tile_layer.local_to_map(tile_layer.to_local(global_pos))
