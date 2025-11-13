# EnemyBase.gd
class_name EnemyBase
extends Node2D

var vita: int
var posizione_tile: Vector2i

@export var tilemap: TileMapLayer
@onready var animation : AnimatedSprite2D = $Animation

func snap_to_tile_center(coords: Vector2i):
	var tile_pos = tilemap.map_to_local(coords)
	global_position = tile_pos - $Center.position

func breath():
	pass

func receive_hit(event_type: String, data := {}):
	match event_type:
		"damage":
			take_damage(data.get("amount", 1))
		"kill":
			die()
		_:
			pass

func take_damage(dmg: int):
	vita -= dmg
	if vita <= 0:
		die()

func die():
	queue_free()
