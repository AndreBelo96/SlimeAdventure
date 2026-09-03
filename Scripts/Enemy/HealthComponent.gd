# Scripts/Enemy/HealthComponent.gd
class_name HealthComponent
extends Resource

var max_life: int
var life: int

func setup(starting_life: int) -> void:
	max_life = starting_life
	life = starting_life

func apply_damage(dmg: int) -> int:
	life -= dmg
	return life

func is_dead() -> bool:
	return life <= 0
