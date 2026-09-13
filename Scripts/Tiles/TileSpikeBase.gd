extends "res://Scripts/Tiles/TileBase.gd"
class_name TileSpikeBase

func on_player_enter():
	if is_active:
		emit_signal("tile_triggered", self, "death", _get_death_data())

func on_enemy_enter(_enemy: EnemyBase):
	if is_active:
		_enemy.receive_hit("damage")
		_on_enemy_hit(_enemy)

func _get_death_data() -> Dictionary:
	return {"death_type": DeathType.Type.SPIKES}

func _on_enemy_hit(_enemy: EnemyBase) -> void:
	pass
