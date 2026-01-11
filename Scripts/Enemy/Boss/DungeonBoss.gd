# Boss.gd
extends EnemyBase

var min_breath_time := 1.0
var max_breath_time := 3.0
var _breath_timer := 0.0
var _waiting_time := 0.0

var step_counter = 0
const STEPS_TO_TRIGGER = 2

@onready var slime := get_tree().get_first_node_in_group("player")
@onready var movement_map :=  $"../../MovementLogicMapLayer"
@onready var visual_map = $"../../TileMapLayer"
var pathfinder: Pathfinder

signal finished_turn(enemy)
signal tile_triggered(tile: TileBase, action: String, data: Dictionary)

func _ready():
	super._ready()
	vita = 3
	posizione_tile = Vector2i(-1, -8)
	snap_to_tile_center(posizione_tile)
	_reset_breath_timer()

func _process(delta: float) -> void:
	match state:
		BossState.IDLE:
			_update_idle(delta)
		BossState.MOVING:
			if not action_in_progress:
				_start_move()
		BossState.ATTACKING:
			if not action_in_progress:
				_start_attack()
		BossState.DEAD:
			pass


### ------- Turn ------- ###

func take_turn():
	if state == BossState.DEAD:
		return
	
	if is_adjacent_to_slime():
		state = BossState.ATTACKING
	else:
		state = BossState.MOVING

### ------- Move ------- ###

func _start_move():
	action_in_progress = true
	
	var next_tile = find_next_tile()
	if next_tile != posizione_tile:
		await move_to(next_tile)

	#_apply_tile_effect_here()
	
	action_in_progress = false
	idle_entered = false
	state = BossState.IDLE
	
	print("MOVIMENTO TERMINATO")
	emit_signal("finished_turn", self)

func _ensure_pathfinder() -> bool:
	
	if pathfinder != null:
		return true

	if movement_map == null or visual_map == null:
		push_error("Boss: movement_map or visual_map is not set!")
		return false

	pathfinder = Pathfinder.new(movement_map, visual_map, GameManager.DIRECTION_BITS)
	return true

func should_move(_step_count: int) -> bool:
	return _step_count % STEPS_TO_TRIGGER == 0

func find_next_tile() -> Vector2i:
	if not _ensure_pathfinder():
		return Vector2i.ZERO
	
	return pathfinder.get_next_step(posizione_tile, slime.movement_handler.grid_position)

func is_adjacent_to_slime() -> bool:
	if not slime:
		return false
	
	var dx = abs(slime.movement_handler.grid_position.x - posizione_tile.x)
	var dy = abs(slime.movement_handler.grid_position.y - posizione_tile.y)
	
	return dx <= 1 and dy <= 1 and not (dx == 0 and dy == 0)

func move_to(next_tile: Vector2i):
	animation.play("WALK")
	await _animate_move_to(next_tile)
	posizione_tile = next_tile
	snap_to_tile_center(next_tile)

func _animate_move_to(tile: Vector2i) -> void:
	var target_pos = tilemap.map_to_local(tile) - $Center.position
	var tween = create_tween()
	tween.tween_property(self, "global_position", target_pos, 0.2)
	await tween.finished


### ------- Take Dmg ------- ###

func damage_animation():
	animation.modulate = Color(2, 2, 2)
	await get_tree().create_timer(0.2).timeout
	animation.modulate = Color(1, 1, 1)
	
	var tween := create_tween()
	tween.tween_property(self, "position:y", position.y - 20, 0.15)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)

	tween.tween_property(self, "position:y", position.y, 0.2)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN)
	
	pass

func _apply_tile_effect_here():
	print("--- NON ENTRA TILE EFFECT ENEMY---")
	if level_logic:
		level_logic.apply_tile_effect_to_enemy(self, posizione_tile)

### ------- Attack ------- ###

func _start_attack():
	action_in_progress = true
	
	slime.lock_input()
	animation.play("ATTACK")
	await animation.animation_finished
	attack()
	
	action_in_progress = false
	idle_entered = false
	state = BossState.IDLE

func attack():
	emit_signal("tile_triggered", self, "death", {"death_type": GameManager.Death.ENEMY})

### ------- Breath ------- ###

func _update_idle(delta):
	if not idle_entered:
		animation.play("IDLE")
		idle_entered = true
	
	_breath_timer += delta
	if _breath_timer >= _waiting_time:
		_start_breath()
		idle_entered = false

func _start_breath():
	if animation.is_playing():
		return
	animation.play("BREATH")
	_reset_breath_timer()

func breath():
	_reset_breath_timer()

func _reset_breath_timer():
	_breath_timer = 0.0
	_waiting_time = randf_range(min_breath_time, max_breath_time)
