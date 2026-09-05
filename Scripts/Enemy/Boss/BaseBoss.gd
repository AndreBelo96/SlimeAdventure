# EnemyBase.gd
class_name EnemyBase
extends Node2D

enum BossState {
	IDLE,
	MOVING,
	ATTACKING,
	DEAD
}

signal defeated
signal damaged(boss)
signal life_changed(dmg: int)
signal finished_turn(enemy)

@export var tilemap: TileMapLayer
@export var turn_behavior: TurnBehavior

var state: BossState = BossState.IDLE
var action_in_progress := false
var idle_entered := false
var active := false

var vita: int
var posizione_tile: Vector2i

@onready var health := HealthComponent.new()
@onready var grid_movement := GridMovement.new()
@onready var animation: AnimatedSprite2D = $Animation
@onready var level_logic = get_tree().get_first_node_in_group("level_logic")

func _ready():
	add_to_group("enemy")
	active = false
	set_process(false)
	set_physics_process(false)

## Da chiamare dalle classi figlie in _ready() per inizializzare la vita.
func setup_health(starting_life: int) -> void:
	health.setup(starting_life)
	vita = health.life

## Da chiamare dalle classi figlie in _ready() per inizializzare la griglia.
func setup_grid(_tilemap: TileMapLayer, center_offset: Vector2, start_pos: Vector2i, movement_map: TileMapLayer = null, visual_map: TileMapLayer = null) -> void:
	grid_movement.setup(self, _tilemap, center_offset, start_pos, movement_map, visual_map)
	posizione_tile = grid_movement.grid_position

func should_move(_step_count: int) -> bool:
	return true

func take_turn():
	push_error("EnemyBase.take_turn() non implementato in %s" % self)

func breath():
	pass  # hook opzionale: non tutti i nemici hanno un'animazione di "respiro" idle

## Le classi figlie che usano ChaseBehavior devono implementarlo (es. posizione del player).
func get_target_position() -> Vector2i:
	push_error("EnemyBase.get_target_position() non implementato")
	return Vector2i.ZERO

func receive_hit(event_type: String, data := {}):
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
	health.apply_damage(dmg)
	vita = health.life
	change_steps()

	emit_signal("life_changed", dmg)
	emit_signal("damaged", self)

	if health.is_dead():
		die()

func damage_animation():
	pass  # hook opzionale: non tutti i nemici hanno un feedback visivo al danno

func die():
	if state == BossState.DEAD:
		return

	state = BossState.DEAD
	animation.play("DEATH")
	emit_signal("defeated")

func change_steps():
	pass  # hook opzionale: non tutti i nemici modificano il proprio timing quando colpiti

func activate():
	active = true
	set_process(true)
	set_physics_process(true)

func is_dead() -> bool:
	return state == BossState.DEAD
