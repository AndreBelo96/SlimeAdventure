extends RefCounted
class_name TileSpatialIndex
## Indicizza i TileBase figli di un layer per posizione griglia, con cache lazy.

var _layer: Node2D
var _cache: Dictionary = {}
var _built := false

func _init(layer: Node2D) -> void:
	_layer = layer

func get_tile_at(grid_pos: Vector2i) -> TileBase:
	if _layer == null:
		return null
	if not _built:
		_build()
	return _cache.get(grid_pos, null)

func invalidate() -> void:
	_built = false

func _build() -> void:
	_cache.clear()
	for child in _layer.get_children():
		if child is TileBase:
			var local_pos = child.global_position - _layer.global_position
			var grid_pos = _layer.local_to_map(local_pos)
			_cache[grid_pos] = child
	_built = true
