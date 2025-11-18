# -- LevelLogic.gd -- #
extends Node

@export var player: Node2D
@export var tile_layer: Node2D
@export var boss: EnemyBase

signal global_step(step_count: int)

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

func _on_tile_state_changed(tile: TileBase, new_state: String):
	var tile_pos = tile_layer.local_to_map(tile.position)
	
	if boss.posizione_tile == tile_pos:
		tile.on_enemy_enter(boss)

func _connect_all_tiles() -> void:
	for child in tile_layer.get_children():
		if child is TileBase:
			if not child.is_connected("tile_triggered", Callable(self, "_on_tile_triggered")):
				child.connect("tile_triggered", Callable(self, "_on_tile_triggered"))
			
			# Se non è già connesso il cambio di stato
			if not child.is_connected("state_changed", Callable(self, "_on_tile_state_changed")):
				child.connect("state_changed", Callable(self, "_on_tile_state_changed"))

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

func on_player_step(step_count: int):
	emit_signal("global_step", step_count)
