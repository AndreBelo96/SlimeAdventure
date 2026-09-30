class_name WarningPainter
extends RefCounted
## Tiene traccia delle celle segnate da una sorgente (nemico, boss)
## e le pulisce tutte insieme.

var _source: Object
var _tile_index: TileSpatialIndex
var _tiles: Array[TileBase] = []

func _init(source: Object, tile_index: TileSpatialIndex) -> void:
	_source = source
	_tile_index = tile_index

func paint(cell: Vector2i, warning_color: Color, priority := 0) -> void:
	var tile := _tile_index.get_tile_at(cell)
	if tile == null:
		return
	tile.set_warning(_source, warning_color, priority)
	_tiles.append(tile)

func clear() -> void:
	for t in _tiles:
		if is_instance_valid(t):
			t.clear_warning(_source)
	_tiles.clear()
