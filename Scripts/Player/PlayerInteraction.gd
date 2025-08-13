class_name PlayerInteraction
extends Resource

const DeathType = preload("res://Scripts/Player/DeathType.gd").DeathType

var player
var tile_map_layer

func setup(player_ref, tile_layer):
	player = player_ref
	tile_map_layer = tile_layer

func check_tile():
	var tile_found = false
	for child in tile_map_layer.get_children():
		if child.has_node("Center"):
			var center = child.get_node("Center")
			var coords = player.movement_handler.get_coords_from_global_position(center.global_position)
			if coords == player.movement_handler.grid_position:
				tile_found = true
				if child.has_method("on_player_enter"):
					child.on_player_enter()
				break
	if not tile_found:
		player.on_player_died(DeathType.VOID)

	check_victory()

func check_victory():
	for child in tile_map_layer.get_children():
		if child.has_method("is_activated") and not child.is_activated():
			return
	player.on_player_won()
