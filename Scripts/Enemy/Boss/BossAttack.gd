# Scripts/Enemy/Boss/BossAttack.gd
class_name BossAttack
extends Resource

var boss: Node2D
var ceiling_debris_scene: PackedScene
var camera: Camera2D
var warning_color: Color

var _warnings: WarningPainter

func setup(_boss: Node2D, _ceiling_debris_scene: PackedScene, _camera: Camera2D, tile_index: GridSpatialIndex, _warning_color: Color) -> void:
	boss = _boss
	ceiling_debris_scene = _ceiling_debris_scene
	camera = _camera
	warning_color = _warning_color
	_warnings = WarningPainter.new(_boss, tile_index)

func get_attack_tiles(origin: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for dx in [-1, 0, 1]:
		for dy in [-1, 0, 1]:
			if dx == 0 and dy == 0:
				continue
			result.append(origin + Vector2i(dx, dy))
	return result

func show_attack_warning(origin: Vector2i) -> void:
	for cell in get_attack_tiles(origin):
		_warnings.paint(cell, warning_color, TileWarning.Priority.CHARGE)

func clear_attack_warning() -> void:
	_warnings.clear()

func spawn_ceiling_debris() -> void:
	if ceiling_debris_scene == null or camera == null:
		return
	var debris = ceiling_debris_scene.instantiate()
	camera.add_child(debris)
	debris.position = Vector2(0, -90) # TODO fixme
	debris.play()
