class_name PlayerInput
extends Resource

var directions := {
	"move_up": Vector2i(0, -1),
	"move_right": Vector2i(1, 0),
	"move_down": Vector2i(0, 1),
	"move_left": Vector2i(-1, 0)
}

func get_direction(event) -> Vector2i:
	for action in directions.keys():
		if event.is_action_pressed(action):
			return directions[action]
	return Vector2i.ZERO
