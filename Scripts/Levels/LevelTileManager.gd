# TileManager.gd
extends Node
class_name LevelTileManager

signal all_tiles_activated
signal tile_progress_changed(activated: int, total: int)

@export var tile_layer: Node2D
@export var logic_map: TileMapLayer

func _ready():
	connect_tiles()
	assign_keys()
	update_progress()

func initialize():
	update_progress()

func connect_tiles():
	for child in tile_layer.get_children():
		if child.has_signal("tile_state_changed"):
			child.tile_state_changed.connect(update_progress)

func assign_keys():
	var area = logic_map.get_used_rect()
	for y in range(area.position.y, area.end.y):
		for x in range(area.position.x, area.end.x):
			var cell = Vector2i(x, y)
			var tile_data = logic_map.get_cell_tile_data(cell)
			if tile_data == null:
				continue
			var chiave = tile_data.get_custom_data("chiave")
			
			for nodo in tile_layer.get_children():
				if tile_layer.local_to_map(nodo.position) == cell:
					if nodo.is_in_group("spine") or nodo.is_in_group("interruttori"):
						nodo.chiave = chiave

func update_progress():
	var total := 0
	var activated := 0
	for child in tile_layer.get_children():
		if child.has_method("is_activated"):
			total += 1
			if child.is_activated():
				activated += 1
	emit_signal("tile_progress_changed", activated, total)
	if activated == total and total > 0:
		emit_signal("all_tiles_activated")

func get_exit_position() -> Vector2:
	var area = logic_map.get_used_rect()
	for y in range(area.position.y, area.end.y):
		for x in range(area.position.x, area.end.x):
			var cell = Vector2i(x, y)
			var tile_data = logic_map.get_cell_tile_data(cell)
			if tile_data == null:
				continue
			if tile_data.get_custom_data("chiave") == "EXIT":
				return cell
	return Vector2.ZERO

func activate_exit_particles(exit_cell: Vector2i):
	for nodo in tile_layer.get_children():
		if tile_layer.local_to_map(nodo.position) == exit_cell:
			if nodo.has_node("GlowParticles"):
				var particles = nodo.get_node("GlowParticles") as GPUParticles2D
				particles.emitting = true
			return
