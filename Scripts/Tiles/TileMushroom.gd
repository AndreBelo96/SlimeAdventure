extends "res://Scripts/Tiles/TileBase.gd"
class_name TileMushroom

const FOG_SCENE := preload("res://Scenes/Effects/ConfusionFog.tscn")

@export var confusion_steps := 3
@export var include_diagonals := true

var _cell: Vector2i
const FOG_SPREAD := 0.5

func _ready():
	super._ready()
	
	set_region_from_coords(LocationManager.MUSHROOM_TILE_POSITION, LocationManager.get_tileset_row_for_level())
	sprite.texture = atlas_texture
	sprite.modulate = Color(0.75, 0.35, 0.95)   # PLACEHOLDER
	weight = 999
	_cell = get_parent().local_to_map(position)
	print("Fungo cella=", _cell, " Center=", has_node("Center"), " layer=", get_parent().name)
	_spawn_fog()

func can_enter() -> bool:
	print("can_enter chiamato sul fungo ", _cell)
	return false

func setup_level_logic(level_logic) -> void:
	level_logic.global_step.connect(_on_global_step)

func _on_global_step(_step_count: int) -> void:
	var player = PlayerRef.player
	if player and _is_near(player.grid_position):
		player.apply_confusion(confusion_steps)

func _is_near(pos: Vector2i) -> bool:
	if include_diagonals:
		return GridUtils.is_adjacent_8(_cell, pos)
	return GridUtils.is_adjacent_4(_cell, pos)

# -----------------------
# Nebbia (area d'effetto visibile)
# -----------------------
func _spawn_fog() -> void:
	var layer := get_parent() as TileMapLayer
	var origin := layer.map_to_local(_cell)

	var fog: ConfusionFog = FOG_SCENE.instantiate()
	add_child(fog)                       # prima nell'albero, poi setup
	fog.position = origin - position     # centro cella, indipendente dall'origine della scena
	fog.setup(_get_fog_points(layer, origin))

func _get_fog_points(layer: TileMapLayer, origin: Vector2) -> PackedVector2Array:
	var half := Vector2(layer.tile_set.tile_size) / 2.0
	var corners: Array[Vector2] = [
		Vector2(half.x, 0), Vector2(-half.x, 0),
		Vector2(0, half.y), Vector2(0, -half.y)
	]

	var points := PackedVector2Array()
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			var cell := _cell + Vector2i(dx, dy)
			if cell != _cell and not _is_near(cell):
				continue
			var center := layer.map_to_local(cell) - origin
			points.append(center)
			for corner in corners:
				points.append(center + corner * FOG_SPREAD)
	return points
