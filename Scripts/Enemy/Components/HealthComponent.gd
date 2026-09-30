# Scripts/Enemy/HealthComponent.gd
class_name HealthComponent
extends Resource

var max_life: int
var life: int

func setup(starting_life: int) -> void:
	max_life = starting_life
	life = starting_life
	emit_changed()

func apply_damage(dmg: int) -> int:
	life = max(life - dmg, 0)
	emit_changed()
	return life

func is_dead() -> bool:
	return life <= 0
