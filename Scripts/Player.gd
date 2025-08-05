extends Node2D

signal player_died
signal player_won
signal steps_changed(new_count: int)

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var tile_map_layer = $"../../TileMapLayer"
@onready var wall_map_layer = $"../WallMapLayer"
@onready var wall_back_map_layer = $"../WallBackMapLayer"

var input_enabled := true

@export var move_duration := 0.2

var grid_position := Vector2i(0, 0)
var is_moving := false
var steps: int = 0

func _ready():
	grid_position = _get_coords_from_global_position(global_position)
	_snap_to_tile_center(grid_position)
	anim.play("Idle")
	
	await get_tree().process_frame
	call_deferred("_check_tile")

func _unhandled_input(event):
	if is_moving || not input_enabled:
		return

	var direction := Vector2i.ZERO

	if event.is_action_pressed("move_up"):
		direction = Vector2i(0, -1)
	elif event.is_action_pressed("move_right"):
		direction = Vector2i(1, 0)
	elif event.is_action_pressed("move_down"):
		direction = Vector2i(0, 1)
	elif event.is_action_pressed("move_left"):
		direction = Vector2i(-1, 0)

	if direction != Vector2i.ZERO:
		move_to(grid_position + direction)

func move_to(new_grid_position: Vector2i) -> void:
	
	if is_wall_at(new_grid_position) or not can_move_to(new_grid_position):
		await bounce_off(new_grid_position)
		return
		
	is_moving = true
	anim.play("Move")
	grid_position = new_grid_position
	var target_position = _get_tile_center_position(grid_position)
	var tween := create_tween()
	tween.tween_property(self, "global_position", target_position, move_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	steps += 1
	emit_signal("steps_changed", steps)
	anim.play("Idle")
	is_moving = false
	_check_tile()

func _check_tile():
	var tile_found = false
	for child in tile_map_layer.get_children():
		if child.has_node("Center"):
			var center = child.get_node("Center")
			var coords = _get_coords_from_global_position(center.global_position)
			if coords == grid_position:
				tile_found = true
				if child.has_method("on_player_enter"):
					child.on_player_enter()
				break

	if not tile_found:
		_handle_death()

	_check_victory()

func _check_victory():
	for child in tile_map_layer.get_children():
		if child.has_method("is_activated") and not child.is_activated():
			return
	input_enabled = false
	emit_signal("player_won")

func _handle_death():
	is_moving = true
	anim.play("Death")
	emit_signal("player_died")

func _get_tile_center_position(coords: Vector2i) -> Vector2:
	for child in tile_map_layer.get_children():
		if child.has_node("Center"):
			var center = child.get_node("Center")
			var center_coords = _get_coords_from_global_position(center.global_position)
			if center_coords == coords:
				return center.global_position
	return tile_map_layer.to_global(tile_map_layer.map_to_local(coords))

func _get_coords_from_global_position(global_pos: Vector2) -> Vector2i:
	var local_pos = tile_map_layer.to_local(global_pos)
	return tile_map_layer.local_to_map(local_pos)

func _get_coords_from_global_position_for_walls(global_pos: Vector2) -> Vector2i:
	var local_pos = wall_map_layer.to_local(global_pos)
	return wall_map_layer.local_to_map(local_pos)

func _get_coords_from_global_position_for_walls_back(global_pos: Vector2) -> Vector2i:
	var local_pos = wall_back_map_layer.to_local(global_pos)
	return wall_back_map_layer.local_to_map(local_pos)

func _snap_to_tile_center(coords: Vector2i):
	global_position = _get_tile_center_position(coords)

func can_move_to(coords: Vector2i) -> bool:
	for child in tile_map_layer.get_children():
		if child.has_node("Center"):
			var center = child.get_node("Center")
			var child_coords = _get_coords_from_global_position(center.global_position)
			if child_coords == coords:
				return child.has_method("can_enter") and child.can_enter()
	return true

func is_wall_at(coords: Vector2i) -> bool:
	for child in wall_map_layer.get_children():
		if child.has_node("Center"):
			var center = child.get_node("Center")
			var child_coords = _get_coords_from_global_position_for_walls(center.global_position)
			if child_coords == coords:
				return true
	for child in wall_back_map_layer.get_children():
		if child.has_node("Center"):
			var center = child.get_node("Center")
			var child_coords = _get_coords_from_global_position_for_walls_back(center.global_position)
			if child_coords == coords:
				return true
	return false

func bounce_off(blocked_position: Vector2i) -> void:
	is_moving = true
	anim.play("Move")

	var blocked_world_pos = _get_tile_center_position(blocked_position)
	var bounce_distance: Vector2 = (blocked_world_pos - global_position) * 0.3  # piccolo movimento verso

	var tween := create_tween()
	tween.tween_property(self, "global_position", global_position + bounce_distance, move_duration * 0.4)
	tween.tween_property(self, "global_position", global_position, move_duration * 0.4)
	await tween.finished

	anim.play("Idle")
	is_moving = false
