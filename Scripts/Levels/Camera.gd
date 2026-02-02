extends Camera2D

@export var shake_strength := 8.0
@export var shake_duration := 0.2

var _shake_time := 0.0

func get_player_position_rounded() -> Vector2:
	var player = $"../YSort/Player"
	return Vector2(round(player.global_position.x), round(player.global_position.y))

func shake(strength := shake_strength, duration := shake_duration):
	shake_strength = strength
	_shake_time = duration

func _process(_delta: float) -> void:
	global_position = $"../YSort/Player".global_position

	if _shake_time > 0:
		_shake_time -= _delta
		offset = Vector2(
			round(randf_range(-shake_strength, shake_strength)),
			round(randf_range(-shake_strength, shake_strength))
		)
	else:
		offset = Vector2.ZERO
