# Scripts/Enemy/Boss/BossAttack.gd
class_name BossAttack
extends Resource

var boss: Node2D
var warning_tile_scene: PackedScene
var ceiling_debris_scene: PackedScene
var camera: Camera2D

var active_warnings: Array[Node2D] = []

func setup(_boss: Node2D, _warning_tile_scene: PackedScene, _ceiling_debris_scene: PackedScene, _camera: Camera2D) -> void:
	boss = _boss
	warning_tile_scene = _warning_tile_scene
	ceiling_debris_scene = _ceiling_debris_scene
	camera = _camera

func get_attack_tiles(origin: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for dx in [-1, 0, 1]:
		for dy in [-1, 0, 1]:
			if dx == 0 and dy == 0:
				continue
			result.append(origin + Vector2i(dx, dy))
	return result

func show_attack_warning(origin: Vector2i, tilemap: TileMapLayer) -> void:
	if warning_tile_scene == null:
		push_error("BossAttack: warning_tile_scene non impostato")
		return

	for cell in get_attack_tiles(origin):
		var warning_tile := warning_tile_scene.instantiate()
		warning_tile.global_position = tilemap.map_to_local(cell)
		boss.get_tree().current_scene.add_child(warning_tile)
		active_warnings.append(warning_tile)

func clear_attack_warning() -> void:
	for warning in active_warnings:
		if is_instance_valid(warning):
			warning.queue_free()
	active_warnings.clear()

func spawn_ceiling_debris() -> void:
	if ceiling_debris_scene == null or camera == null:
		return

	var debris = ceiling_debris_scene.instantiate()
	camera.add_child(debris)
	debris.position = Vector2(0, -90) # TODO fixme
	debris.play()
