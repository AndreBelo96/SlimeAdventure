class_name TileWarning
extends Polygon2D
## Rombo pulsante che segnala pericolo su una cella. Creato on demand da TileBase.
## Più sorgenti possono segnare la stessa cella: vince la priorità più alta.

enum Priority { SIGHT, STEP, CHARGE }

const ALPHA_MIN := 0.4
const PULSE_TIME := 0.4

var _sources := {}   # sorgente -> [colore, priorità]
var _tween: Tween

func setup(tile_size: Vector2) -> void:
	var half := tile_size / 2.0
	polygon = PackedVector2Array([
		Vector2(0, -half.y), Vector2(half.x, 0),
		Vector2(0, half.y), Vector2(-half.x, 0)
	])
	visible = false

func set_source(source: Object, warning_color: Color, priority: int) -> void:
	_sources[source] = [warning_color, priority]
	_refresh()

func clear_source(source: Object) -> void:
	_sources.erase(source)
	_refresh()

func _refresh() -> void:
	if _tween:
		_tween.kill()
	visible = not _sources.is_empty()
	if not visible:
		return

	var best: Array = _sources.values()[0]
	for w in _sources.values():
		if w[1] > best[1]:
			best = w
	color = best[0]

	_tween = create_tween().set_loops()
	_tween.tween_property(self, "modulate:a", 1.0, PULSE_TIME).from(ALPHA_MIN)
	_tween.tween_property(self, "modulate:a", ALPHA_MIN, PULSE_TIME)
