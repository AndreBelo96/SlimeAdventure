# -- LevelLogic.gd -- #
extends Node

@export var player: Node2D
@export var tile_layer: Node2D

func _ready():
	call_deferred("_connect_all_tiles")
	call_deferred("_connect_player_signal")
	add_to_group("level_logic")

# ------ Enemy ------ #
func apply_tile_effect_to_enemy(enemy: EnemyBase, pos: Vector2i):
	var tile = get_tile_under_enemy(pos)
	if tile and tile.has_method("on_enemy_enter"):
		tile.on_enemy_enter(enemy)

func get_tile_under_enemy(pos: Vector2i) -> TileBase:
	var target_world_pos = tile_layer.to_global(tile_layer.map_to_local(pos))
	for child in tile_layer.get_children():
		if child is TileBase:
			if child.global_position.distance_to(target_world_pos) < 1.0:
				return child
	
	return null

func _connect_all_tiles() -> void:
	for child in tile_layer.get_children():
		if child is TileBase:
			if not child.is_connected("tile_triggered", Callable(self, "_on_tile_triggered")):
				child.connect("tile_triggered", Callable(self, "_on_tile_triggered"))

func _connect_player_signal():
	var level_manager = get_parent()
	if level_manager:
		level_manager.connect("signal_victory", Callable(self, "check_victory"))

func _on_tile_triggered(sender, action: String, data: Dictionary) -> void:
	match action:
		"death":
			GameLogger.warn("Morte: tipo=%s sender=%s pos=%s" % [str(data.get("death_type", 0)), sender.name, str(sender.global_position)])
			player.on_player_died(data.get("death_type", 0))
		"activate":
			sender.is_active = data.get("is_active", true)
			GameLogger.info("Tile attivata: %s stato=%s pos=%s" % [sender.name, str(sender.is_active), str(sender.global_position)])
		"switch":
			var chiave = data.get("chiave", "")
			var azione = data.get("azione", "disattiva")
			GameLogger.info("Switch sender=%s chiave=%s azione=%s" % [sender.name, chiave, azione])
			_handle_switch(chiave, azione)
		_:
			GameLogger.info("Sender %s azione=%s dati=%s" % [sender.name, action, str(data)])

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
