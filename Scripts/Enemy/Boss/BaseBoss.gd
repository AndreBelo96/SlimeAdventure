# EnemyBase.gd
class_name EnemyBase
extends Node2D

enum BossState {
	IDLE,
	MOVING,
	ATTACKING,
	DEAD
}

var state: BossState = BossState.IDLE
var action_in_progress := false
var idle_entered := false

var vita: int
var active := false
var posizione_tile: Vector2i

@export var tilemap: TileMapLayer
@onready var animation : AnimatedSprite2D = $Animation
@onready var level_logic = get_tree().get_first_node_in_group("level_logic")

signal defeated
signal damaged(boss)

func _ready():
	add_to_group("enemy")
	active = false
	set_process(false)
	
	set_physics_process(false)
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
	print("HIT BOSS")
	match event_type:
		"damage":
			take_damage(data.get("amount", 1))
		"kill":
			die()
		_:
			pass

func take_damage(dmg: int):
	if state == BossState.DEAD:
		return
	
	damage_animation()
	
	vita -= dmg
	
	change_steps()
	
	# Aggiorna la barra HUD
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.update_progress_bar(dmg)
	
	emit_signal("damaged", self)
	
	if vita <= 0:
		die()

func damage_animation():
	pass

func die():
	if state == BossState.DEAD:
		return

	state = BossState.DEAD
	animation.play("DEATH")
	emit_signal("defeated")

func change_steps():
	pass

func activate():
	active = true
	set_process(true)
	set_physics_process(true)
