# Scripts/Enemy/EnemyBase.gd
class_name EnemyBase
extends Node2D

## Base comune a TUTTI i nemici (semplici e boss): griglia, vita, turno, morte.

signal defeated

var turn_behavior: TurnBehavior
var grid_position: Vector2i
var _dead := false

@onready var health := HealthComponent.new()
@onready var grid_movement := GridMovement.new()
@onready var animation: AnimatedSprite2D = $Animation
@onready var health_bar: EnemyHealthBar = $HealthBar


func _ready():
	add_to_group("enemy")

func setup_health(starting_life: int) -> void:
	health.setup(starting_life)
	if health_bar:
		health_bar.bind(health)

func setup_grid(_tilemap: TileMapLayer, center_offset: Vector2, start_pos: Vector2i, movement_map: TileMapLayer = null, visual_map: TileMapLayer = null) -> void:
	grid_movement.setup(self, _tilemap, center_offset, start_pos, movement_map, visual_map)
	grid_position = grid_movement.grid_position

# ---------- Turno ----------
func should_move(_step_count: int) -> bool:
	return true

func take_turn():
	push_error("EnemyBase.take_turn() non implementato in %s" % self)

## true  = il player muore appena entra nella cella del nemico (boss)
## false = il nemico risolve il contatto dopo la propria mossa (nemici semplici)
func checks_contact_on_player_move() -> bool:
	return false

## Da implementare nei nemici che usano ChaseBehavior.
func get_target_position() -> Vector2i:
	push_error("EnemyBase.get_target_position() non implementato")
	return Vector2i.ZERO

# ---------- Danno e morte ----------
func receive_hit(event_type: String, data := {}):
	match event_type:
		"damage":
			take_damage(data.get("amount", 1))
		"kill":
			die()

func take_damage(dmg: int):
	if is_dead():
		return
	health.apply_damage(dmg)
	_on_damaged(dmg)
	await damage_animation()
	if health.is_dead():
		die()

func _on_damaged(_dmg: int) -> void:
	pass   # hook: il boss aggiorna HP bar e ritmo

func damage_animation():
	pass   # hook: feedback visivo al danno

func die():
	if is_dead():
		return
	_dead = true
	animation.play("DEATH")
	emit_signal("defeated")

func is_dead() -> bool:
	return _dead
