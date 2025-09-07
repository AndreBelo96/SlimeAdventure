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
	match action:
		"death":
			Logger.warn("Morte: tipo=%s tile=%s pos=%s" % [str(data.get("death_type", 0)), tile.name, str(tile.global_position)])
			player.on_player_died(data.get("death_type", 0))
		"activate":
			tile.is_active = data.get("is_active", true)
			Logger.info("Tile attivata: %s stato=%s pos=%s" % [tile.name, str(tile.is_active), str(tile.global_position)])
		"switch":
			var chiave = data.get("chiave", "")
			Logger.info("Switch tile=%s chiave=%s" % [tile.name, chiave])
			_unlock_spikes(chiave)
		_:
			Logger.info("Tile %s azione=%s dati=%s" % [tile.name, action, str(data)])

func _unlock_spikes(chiave: String):
	for child in tile_layer.get_children():
		if child.is_in_group("spine") and child.chiave == chiave:
			Logger.info("Spine sbloccate con chiave=%s" % chiave)
			child.disattiva()

func check_victory():
	var level_manager = get_parent()
	
	if player is not Node2D or not level_manager or level_manager.exit_position == Vector2.ZERO:
		return
	
	var player_tile = get_coords_from_global_position(player.position)
	var exit_tile = Vector2i(level_manager.exit_position)
	
	if player_tile == exit_tile and level_manager.all_tiles_active:
		player.on_player_won()

func get_coords_from_global_position(global_pos: Vector2) -> Vector2i:
	return tile_layer.local_to_map(tile_layer.to_local(global_pos))
