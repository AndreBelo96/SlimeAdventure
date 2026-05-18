# Scripts/Levels/EnemyTurnHandler.gd
extends Resource
class_name EnemyTurnHandler

signal enemy_turn_done(enemy)

var tile_layer: Node2D

func setup(_tile_layer: Node2D) -> void:
	tile_layer = _tile_layer

func process_enemies(step_count: int, scene_tree) -> void:
	for enemy in scene_tree.get_nodes_in_group("enemy"):
		if enemy.should_move(step_count):
			enemy.take_turn()
		else:
			emit_signal("enemy_turn_done", enemy)

func on_enemy_finished_turn(enemy) -> void:
	emit_signal("enemy_turn_done", enemy)

func apply_tile_effect(enemy) -> void:
	var tile = get_tile_under_enemy(enemy.posizione_tile)
	if tile and tile.has_method("on_enemy_enter"):
		tile.on_enemy_enter(enemy)

func get_tile_under_enemy(pos: Vector2i) -> TileBase:
	var target_pos = tile_layer.to_global(tile_layer.map_to_local(pos))
	for child in tile_layer.get_children():
		if child is TileBase:
			if child.global_position.distance_to(target_pos) < 1.0:
				return child
	return null
