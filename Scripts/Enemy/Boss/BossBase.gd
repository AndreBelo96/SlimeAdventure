# Scripts/Enemy/Boss/BossBase.gd
class_name BossBase
extends EnemyBase

## Base dei boss: macchina a stati, barra vita, ritmo variabile, sincronizzazione switch/spine.

enum BossState { IDLE, MOVING, ATTACKING, DEAD }

signal damaged(boss)
signal life_changed(dmg: int)
@warning_ignore("UNUSED_SIGNAL")
signal finished_turn(enemy)

@export var tilemap: TileMapLayer

var state: BossState = BossState.IDLE
var action_in_progress := false
var idle_entered := false
var active := false
var health_points: int
var level_logic = null

func _ready():
	super._ready()
	add_to_group("boss")
	active = false
	set_process(false)
	set_physics_process(false)

func setup_health(starting_life: int) -> void:
	super.setup_health(starting_life)
	health_points = health.life

func setup_level_logic(_level_logic) -> void:
	level_logic = _level_logic

func checks_contact_on_player_move() -> bool:
	return true

func _on_damaged(dmg: int) -> void:
	health_points = health.life
	change_steps()
	emit_signal("life_changed", dmg)
	emit_signal("damaged", self)

func die():
	if is_dead():
		return
	state = BossState.DEAD
	super.die()

func breath():
	pass   # hook: respiro in idle

func change_steps():
	pass   # hook: cambio di ritmo quando colpito

func activate():
	active = true
	set_process(true)
	set_physics_process(true)
