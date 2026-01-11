# -- LevelLogic.gd -- #
extends Node

@export var player: Node2D
@export var tile_layer: Node2D
@export var boss: EnemyBase

var boss_hit_by_switch := false
var switch_waiting_reset := false
var last_switch_pressed = null

# -- Enemies --
var _enemy_phase_done := false
var _tiles_phase_done := false


signal global_step(step_count: int)

func _ready():
	add_to_group("level_logic")
	
	call_deferred("_connect_all_tiles")
	call_deferred("_connect_player_signal")
	
	boss.connect("finished_turn", Callable(self, "_on_enemy_finished_turn"))

# ------ Enemy ------ #
func apply_tile_effect_to_enemy(enemy: EnemyBase, pos: Vector2i):
	print(" - TILE EFFECT - ")
	var tile = get_tile_under_enemy(pos)
	if tile and tile.has_method("on_enemy_enter"):
		print("TILE EXIST AT POS: " + str(pos))
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
			
			### Se non è già connesso il cambio di stato
			#if not child.is_connected("state_changed", Callable(self, "_on_tile_state_changed")):
				#child.connect("state_changed", Callable(self, "_on_tile_state_changed"))

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
			var azione = data.get("azione", "")
			
			if azione == "attiva":
				last_switch_pressed = sender
			
			GameLogger.info("Switch sender=%s chiave=%s azione=%s" % [sender.name, chiave, azione])
			_handle_switch(chiave, azione)
			_tiles_phase_done = true
			_try_resolve_enemy_damage(boss)
		"enemy_hit":
			boss_hit_by_switch = true
		_:
			GameLogger.info("Sender %s azione=%s dati=%s" % [sender.name, action, str(data)])

func _handle_switch(chiave: String, azione: String):
	
	print("Gestione dell'azione: ", azione)
	
	if azione == "attiva":
		boss_hit_by_switch = false
		switch_waiting_reset = true
	
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
	print(" --------- PLAYER STEP TURN --------- ")
	
	_enemy_phase_done = false
	_tiles_phase_done = false
	
	emit_signal("global_step", step_count)
	
	# --- RESET POST SWITCH ---
	if switch_waiting_reset:
		if not boss_hit_by_switch:
			_reset_switch_and_spikes()
		switch_waiting_reset = false
		boss_hit_by_switch = false
	
	# --- Movimento nemici ---
	for enemy in get_tree().get_nodes_in_group("enemy"):
		print("POSIZIONE INIZIALE: " + str(enemy.posizione_tile))
		if enemy.should_move(step_count):
			print(" -- MOVIMENTO -- ")
			enemy.take_turn()
		else:
			print(" -- POSIZIONE FISSA -- ")
			_on_enemy_finished_turn(enemy)

func _on_enemy_finished_turn(enemy):
	print("POSIZIONE POST: " + str(enemy.posizione_tile))
	_enemy_phase_done = true
	_try_resolve_enemy_damage(enemy)

func _try_resolve_enemy_damage(enemy):
	if not _enemy_phase_done:
		return
	if not _tiles_phase_done:
		return

	apply_tile_effect_to_enemy(enemy, enemy.posizione_tile)

	_enemy_phase_done = false
	_tiles_phase_done = false

func _reset_switch_and_spikes():
	if last_switch_pressed and last_switch_pressed.is_in_group("interruttori"):
		last_switch_pressed.reset_switch()

	last_switch_pressed = null

func disable_all_spikes():
	for child in tile_layer.get_children():
		if child.is_in_group("spine"):
			child.disattiva()
