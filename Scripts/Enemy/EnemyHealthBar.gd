class_name EnemyHealthBar
extends Node2D
## Barra vita a segmenti sopra i nemici semplici. Si nasconde da sola con 1 HP.

@export var segment_size := Vector2(3, 1)
@export var segment_gap := 1
@export var filled_color := Color(0.8, 0.15, 0.15)
@export var empty_color := Color(0.15, 0.15, 0.15)
@export var border_color := Color(0.05, 0.05, 0.05)
@export var hide_when_full := false

var _health: HealthComponent

func bind(health: HealthComponent) -> void:
	_health = health
	if not health.changed.is_connected(_refresh):
		health.changed.connect(_refresh)
	_refresh()

func _refresh() -> void:
	var full := _health.life >= _health.max_life
	visible = _health.life > 0 and not (hide_when_full and full)
	queue_redraw()

func _draw() -> void:
	if _health == null:
		return
	var n := _health.max_life
	var total_w := n * segment_size.x + (n - 1) * segment_gap
	var x := -total_w / 2.0
	for i in n:
		var rect := Rect2(Vector2(x, -segment_size.y / 2.0), segment_size)
		draw_rect(rect.grow(1), border_color)
		draw_rect(rect, filled_color if i < _health.life else empty_color)
		x += segment_size.x + segment_gap
