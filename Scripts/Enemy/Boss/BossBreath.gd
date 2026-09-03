# Scripts/Enemy/Boss/BossBreath.gd
class_name BossBreath
extends Resource

var animation: AnimatedSprite2D
var min_time := 1.0
var max_time := 3.0
var _timer := 0.0
var _waiting_time := 0.0

func setup(_animation: AnimatedSprite2D, _min_time := 1.0, _max_time := 3.0) -> void:
	animation = _animation
	min_time = _min_time
	max_time = _max_time
	reset()

## Ritorna true se in questo frame è partita l'animazione di respiro.
func update(delta: float) -> bool:
	_timer += delta
	if _timer < _waiting_time:
		return false

	if animation.is_playing():
		return false

	animation.play("BREATH")
	reset()
	return true

func reset() -> void:
	_timer = 0.0
	_waiting_time = randf_range(min_time, max_time)
