extends Camera2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var target_pos = $"../YSort/Player".global_position
	global_position = Vector2(round(target_pos.x), round(target_pos.y))
