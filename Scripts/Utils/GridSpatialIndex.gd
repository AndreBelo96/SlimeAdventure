extends RefCounted
class_name GridSpatialIndex
## Indicizza i figli di un layer per posizione griglia, usando la posizione
## del nodo "Center" figlio (se presente). Cache lazy, va invalidata a mano
## se in futuro i nodi indicizzati possono spostarsi o cambiare (es. tile
## che crollano/si spostano).

var _layer: Node2D
var _cache: Dictionary = {}
var _built := false

func _init(layer: Node2D) -> void:
	_layer = layer

func get_at(grid_pos: Vector2i) -> Node:
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
		if not child.has_node("Center"):
			continue
		var center = child.get_node("Center")
		var local_pos = center.global_position - _layer.global_position
		var grid_pos = _layer.local_to_map(local_pos)
		_cache[grid_pos] = child
	_built = true
