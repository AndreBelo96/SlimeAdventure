# Boss.gd
extends EnemyBase

var min_breath_time := 1.0
var max_breath_time := 3.0
var _breath_timer := 0.0
var _waiting_time := 0.0
var _is_breathing := false

@onready var level_logic = $LevelLogic

func _ready():
	vita = 3
	posizione_tile = Vector2i(-1, -8)
	snap_to_tile_center(posizione_tile)
	_reset_breath_timer()

func _process(delta: float) -> void:
	if _is_breathing:
		return
	
	_breath_timer += delta
	if _breath_timer >= _waiting_time:
		breath()

func _on_turn():
	if is_adjacent_to_slime():
		carica_attacco()
	else:
		pass
		#move_to()

func is_adjacent_to_slime() -> bool:
	return false
	#return slime.posizione_tile.distance_to(posizione_tile) == 1

func move_to(tile: Vector2i):
	posizione_tile = tile
	snap_to_tile_center(tile)

	if level_logic:
		level_logic.apply_tile_effect_to_enemy(self, tile)

func carica_attacco():
	pass

##################
## -- Breath -- ##
##################

func breath():
	_is_breathing = true
	
	animation.play("BREATH")
	await animation.animation_finished
	
	_is_breathing = false
	animation.play("IDLE")

	_reset_breath_timer()

func _reset_breath_timer():
	_breath_timer = 0.0
	_waiting_time = randf_range(min_breath_time, max_breath_time)
