# Scripts/Enemy/TurnBehavior.gd
class_name TurnBehavior
extends Resource

## Ritorna la tile di destinazione per il turno corrente del nemico.
## Le sottoclassi devono implementarlo.
func get_next_tile(_enemy: EnemyBase) -> Vector2i:
	assert(false, "TurnBehavior.get_next_tile() non implementato")
	return Vector2i.ZERO
