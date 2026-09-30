# Scripts/Enemy/ChaseBehavior.gd
class_name ChaseBehavior
extends TurnBehavior

func get_next_tile(enemy: EnemyBase) -> Vector2i:
	var target := enemy.get_target_position()
	return enemy.grid_movement.get_next_step(target)
