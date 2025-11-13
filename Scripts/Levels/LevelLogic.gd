# -- LevelLogic.gd -- #
extends Node

@export var player: Node2D
@export var tile_layer: Node2D

func _ready():
	call_deferred("_connect_all_tiles")
	call_deferred("_connect_player_signal")

func apply_tile_effect_to_enemy(enemy: EnemyBase, tile: Vector2i):
	var tile_data = tile_layer.get_cell_tile_data(tile)
	if tile_data == null:
		return
	var effect = tile_data.get_custom_data("effect")
	match effect:
		"spike":
			enemy.receive_hit("tile_spike")

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
			GameLogger.warn("Morte: tipo=%s tile=%s pos=%s" % [str(data.get("death_type", 0)), tile.name, str(tile.global_position)])
			player.on_player_died(data.get("death_type", 0))
		"activate":
			tile.is_active = data.get("is_active", true)
			GameLogger.info("Tile attivata: %s stato=%s pos=%s" % [tile.name, str(tile.is_active), str(tile.global_position)])
		"switch":
			var chiave = data.get("chiave", "")
			var azione = data.get("azione", "disattiva")
			GameLogger.info("Switch tile=%s chiave=%s azione=%s" % [tile.name, chiave, azione])
			_handle_switch(chiave, azione)
		_:
			GameLogger.info("Tile %s azione=%s dati=%s" % [tile.name, action, str(data)])

func _handle_switch(chiave: String, azione: String):
	for child in tile_layer.get_children():
		if child.is_in_group("spine") and child.chiave == chiave:
			match azione:
				"attiva":
					child.attiva()
					GameLogger.info("Spine attivate chiave = %s" % chiave)
				"disattiva":
					child.disattiva()
					GameLogger.info("Spine disattivate chiave = %s" % chiave)

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
