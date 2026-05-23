# -- LevelLogic.gd -- #
extends Node

@export var player: Node2D
@export var tile_layer: Node2D
@export var boss: EnemyBase

signal global_step(step_count: int)
signal boss_damaged(hit_count: int)

var boss_hit_count := 0
var _current_enemy = null

# -- Enemies --
var _enemy_phase_done := false
var _tiles_phase_done := false

var switch_spike_handler: SwitchSpikeHandler
var enemy_turn_handler: EnemyTurnHandler


func _ready():
	add_to_group("level_logic")
	
	switch_spike_handler = SwitchSpikeHandler.new()
	switch_spike_handler.setup(tile_layer)

	enemy_turn_handler = EnemyTurnHandler.new()
	enemy_turn_handler.setup(tile_layer)
	
	# collega i segnali degli handler
	switch_spike_handler.switch_action_done.connect(_on_switch_action_done)
	enemy_turn_handler.enemy_turn_done.connect(_on_enemy_turn_done)
	
	if boss:
		boss.connect("finished_turn", Callable(enemy_turn_handler, "on_enemy_finished_turn"))
		boss.connect("damaged", Callable(self, "_on_boss_damaged"))
	
	call_deferred("_connect_all_tiles")

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

func _on_tile_triggered(sender, action: String, data: Dictionary) -> void:
	match action:
		"death":
			GameLogger.warn("Morte: tipo=%s sender=%s pos=%s" % [str(data.get("death_type", 0)), sender.name, str(sender.global_position)])
			player.on_player_died(data.get("death_type", 0))
		"switch":
			var chiave = data.get("chiave", "")
			var azione = data.get("azione", "")
			
			GameLogger.info("Switch sender=%s chiave=%s azione=%s" % [sender.name, chiave, azione])
			switch_spike_handler.handle_switch(chiave, azione, sender)
		"enemy_hit":
			switch_spike_handler.notify_boss_hit()
		_:
			GameLogger.info("Sender %s azione=%s dati=%s" % [sender.name, action, str(data)])

func on_player_step(step_count: int):
	print(" --------- PLAYER STEP TURN --------- ")
	
	_enemy_phase_done = false
	_tiles_phase_done = false
	
	emit_signal("global_step", step_count)
	switch_spike_handler.on_step_begin()
	enemy_turn_handler.process_enemies(step_count, get_tree())
	
	## --- RESET POST SWITCH ---
	#if switch_waiting_reset:
		#if not boss_hit_by_switch:
			#_reset_switch_and_spikes()
		#switch_waiting_reset = false
		#boss_hit_by_switch = false
	#
	## --- Movimento nemici ---
	#for enemy in get_tree().get_nodes_in_group("enemy"):
		#print("POSIZIONE INIZIALE: " + str(enemy.posizione_tile))
		#if enemy.should_move(step_count):
			#print(" -- MOVIMENTO -- ")
			#enemy.take_turn()
		#else:
			#print(" -- POSIZIONE FISSA -- ")
			#_on_enemy_finished_turn(enemy)

func _on_switch_action_done() -> void:
	_tiles_phase_done = true
	_try_resolve_damage()

func _on_enemy_turn_done(enemy) -> void:
	_current_enemy = enemy
	_enemy_phase_done = true
	_try_resolve_damage()

func _try_resolve_damage() -> void:
	if not _enemy_phase_done or not _tiles_phase_done:
		return
	if _current_enemy:
		enemy_turn_handler.apply_tile_effect(_current_enemy)
	_enemy_phase_done = false
	_tiles_phase_done = false

func _on_boss_damaged(_boss) -> void:
	boss_hit_count += 1
	emit_signal("boss_damaged", boss_hit_count)

# --- API pubblica usata da Level13 ---
func disable_all_spikes() -> void:
	switch_spike_handler.disable_all_spikes()

func disable_spikes_with_key(key: String) -> void:
	switch_spike_handler.disable_spikes_with_key(key)
