extends Camera2D

func get_player_position_rounded() -> Vector2:
	var player = $"../YSort/Player"
	return Vector2(round(player.global_position.x), round(player.global_position.y))

func _process(_delta: float) -> void:
	global_position = get_player_position_rounded()
