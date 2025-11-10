# EnemyBase.gd
class_name EnemyBase
extends Node2D

var vita: int
var posizione_tile: Vector2i  # coordinata griglia
@onready var tilemap = get_node("/root/Game/TileMap")

func move_to(_target_tile: Vector2i):
	# Calcolo il percorso dal tile corrente a target_tile (es. usando A*), poi mi sposto di un passo.
	# La conversione da tile a posizione reale si fa con tilemap.map_to_world().
	pass

func take_damage(dmg: int):
	vita -= dmg
	if vita <= 0:
		die()

func die():
	queue_free()
