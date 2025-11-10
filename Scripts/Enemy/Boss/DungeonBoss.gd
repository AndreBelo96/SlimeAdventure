# Boss.gd
extends EnemyBase

func _ready():
	vita = 3  # tre hit necessari

func _on_turn():
	if is_adjacent_to_slime():
		carica_attacco()
	else:
		muovi_verso_slime()

func is_adjacent_to_slime() -> bool:
	return true
	#return slime.posizione_tile.distance_to(posizione_tile) == 1

func muovi_verso_slime():
	pass
	#var target = calculate_next_tile_towards(slime.posizione_tile)
	#move_to(target)

#func calculate_next_tile_towards(slime_tile: Vector2i) -> Vector2i:
	pass

func carica_attacco():
	pass
