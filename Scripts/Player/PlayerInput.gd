class_name PlayerInput
extends Resource

func get_direction(event) -> Vector2i:
	var direction := Vector2i.ZERO
	if event.is_action_pressed("move_up"):
		direction = Vector2i(0, -1)
	elif event.is_action_pressed("move_right"):
		direction = Vector2i(1, 0)
	elif event.is_action_pressed("move_down"):
		direction = Vector2i(0, 1)
	elif event.is_action_pressed("move_left"):
		direction = Vector2i(-1, 0)
	return direction
