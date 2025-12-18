# EnemyBase.gd
class_name EnemyBase
extends Node2D

var vita: int
var active := false
var posizione_tile: Vector2i

@export var tilemap: TileMapLayer
@onready var animation : AnimatedSprite2D = $Animation
@onready var level_logic = get_tree().get_first_node_in_group("level_logic")

signal defeated

func _ready():
	active = false
	set_process(false)
	set_physics_process(false)
	add_to_group("enemy")
	if level_logic:
		if not is_connected("tile_triggered", Callable(level_logic, "_on_tile_triggered")):
			connect("tile_triggered", Callable(level_logic, "_on_tile_triggered"))
	print("Boss ready - level_logic:", level_logic)

func snap_to_tile_center(coords: Vector2i):
	var tile_pos = tilemap.map_to_local(coords)
	global_position = tile_pos - $Center.position

func should_move(_step_count: int) -> bool:
	return true

func take_turn():
	pass

func on_step(_step_count: int):
	pass

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
	damage_animation()
	
	vita -= dmg
	
	# Aggiorna la barra HUD
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.update_progress_bar(dmg)
	
	print("Boss colpito! Vita attuale:", vita)
	if vita <= 0:
		die()

func damage_animation():
	pass

func die():
	print("Il boss è morto!")
	print("Da mettere animazione morte prima del queue free")

	emit_signal("defeated")
	queue_free()

func activate():
	active = true
	set_process(true)
	set_physics_process(true)
