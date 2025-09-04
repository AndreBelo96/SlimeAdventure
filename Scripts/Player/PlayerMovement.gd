class_name PlayerMovement
extends Resource

var player
var tile_map_layer
var npc_map_layer
var movement_logic_map_layer
var doors_map_layer
var move_duration

var grid_position := Vector2i.ZERO
var is_moving := false

func setup(player_ref, tile_layer, movement_logic_layer, doors_layer, npc_layer, duration):
	player = player_ref
	tile_map_layer = tile_layer
	movement_logic_map_layer = movement_logic_layer
	doors_map_layer = doors_layer
	npc_map_layer = npc_layer
	move_duration = duration
	grid_position = get_coords_from_global_position_in_layer(player.global_position, tile_map_layer)

func move_to(new_grid_position: Vector2i):
	if is_moving:
		return
	if is_obstacle_at(new_grid_position) or not can_move_to(new_grid_position):
		await bounce_off(new_grid_position)
		return

	is_moving = true
	player.animation_handler.play_move()

	var start_pos = player.global_position
	grid_position = new_grid_position
	var end_pos = get_tile_center_position(grid_position)
	var dist = start_pos.distance_to(end_pos)
	var jump_height = -min(4 + dist * 0.2, 8)

	await tween_jump(start_pos, end_pos, jump_height, move_duration)

	player.animation_handler.play_idle()
	is_moving = false
	player.on_movement_finished()

func bounce_off(blocked_position: Vector2i):
	is_moving = true
	player.animation_handler.play_move()

	var start_pos = player.global_position
	var blocked_world_pos = get_tile_center_position(blocked_position)
	var mid_pos = start_pos.lerp(blocked_world_pos, 0.3)
	var dist = start_pos.distance_to(mid_pos)
	var jump_height = -min(3 + dist * 0.15, 6)

	# Primo salto verso il muro
	await tween_jump(start_pos, mid_pos, jump_height, move_duration * 0.4)
	SoundManager.play_sfx("res://Assets/Audio/Bounce.wav")
	# Rimbalzo indietro
	await tween_jump(mid_pos, start_pos, jump_height * 0.75, move_duration * 0.3)

	player.animation_handler.play_idle()
	is_moving = false

func tween_jump(start_pos: Vector2, end_pos: Vector2, jump_height: float, duration: float):
	var tween = player.create_tween()
	tween.tween_method(
		func(progress):
			var pos = start_pos.lerp(end_pos, progress)
			var vertical_offset = jump_height * 4 * progress * (1 - progress)
			player.global_position = pos + Vector2(0, vertical_offset), 0.0, 1.0, duration ).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tween.finished
	

func snap_to_tile_center(coords: Vector2i):
	player.global_position = get_tile_center_position(coords)

func get_tile_center_position(coords: Vector2i) -> Vector2:
	for child in tile_map_layer.get_children():
		if child.has_node("Center"):
			var center = child.get_node("Center")
			if get_coords_from_global_position_in_layer(center.global_position, tile_map_layer) == coords:
				return center.global_position
	return tile_map_layer.to_global(tile_map_layer.map_to_local(coords))

func get_coords_from_global_position_in_layer(global_pos: Vector2, layer: TileMapLayer) -> Vector2i:
	return layer.local_to_map(layer.to_local(global_pos))

func can_move_to(coords: Vector2i) -> bool:
	return can_move_static(coords) and can_move_to_tile(coords)

func can_move_to_tile(coords: Vector2i) -> bool:
	for child in tile_map_layer.get_children():
		if child.has_node("Center"):
			var center = child.get_node("Center")
			if get_coords_from_global_position_in_layer(center.global_position, tile_map_layer) == coords:
				return child.has_method("can_enter") and child.can_enter()
	return true

func is_obstacle_at(coords: Vector2i) -> bool:
	for child in doors_map_layer.get_children():
		if get_coords_from_global_position_in_layer(child.get_node("Center").global_position, doors_map_layer) == coords and !child.is_open:
			return true
	for child in npc_map_layer.get_children():
		if get_coords_from_global_position_in_layer(child.get_node("Center").global_position, npc_map_layer) == coords:
			return true
	return false

func can_move_static(coords: Vector2i) -> bool:
	var tile_data = movement_logic_map_layer.get_cell_tile_data(grid_position)
	if tile_data == null:
		return true
	
	var mask = tile_data.get_custom_data("MovementMask")
	if mask == null:
		return true
	
	var dir = coords - grid_position
	var dir_bit = 0
	if dir == Vector2i(0, -1): dir_bit = 1 # Nord
	elif dir == Vector2i(1, 0): dir_bit = 2 # Est
	elif dir == Vector2i(0, 1): dir_bit = 4 # Sud
	elif dir == Vector2i(-1, 0): dir_bit = 8 # Ovest

	return (mask & dir_bit) == 0
