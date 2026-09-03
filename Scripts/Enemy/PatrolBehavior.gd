# Scripts/Enemy/PatrolBehavior.gd
class_name PatrolBehavior
extends TurnBehavior

@export var directions: Array[Vector2i] = []

var _index := 0

func get_next_tile(enemy: EnemyBase) -> Vector2i:
	if directions.is_empty():
		return enemy.grid_movement.grid_position

	var dir := directions[_index % directions.size()]
	_index += 1
	return enemy.grid_movement.grid_position + dir
