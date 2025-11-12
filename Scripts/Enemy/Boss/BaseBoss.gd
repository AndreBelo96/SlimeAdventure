# EnemyBase.gd
class_name EnemyBase
extends Node2D

var vita: int
var posizione_tile: Vector2i

@export var tilemap: TileMapLayer
@onready var animation : AnimatedSprite2D = $Animation

func snap_to_tile_center(coords: Vector2i):
	var tile_local = tilemap.map_to_local(coords)
	var tile_global = tilemap.to_global(tile_local)
	global_position = tile_global - ($Center.position)

func breath():
	pass

func take_damage(dmg: int):
	vita -= dmg
	if vita <= 0:
		die()

func die():
	queue_free()
