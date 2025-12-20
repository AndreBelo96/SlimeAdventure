# Boss.gd
extends EnemyBase

var min_breath_time := 1.0
var max_breath_time := 3.0
var _breath_timer := 0.0
var _waiting_time := 0.0
var _is_breathing := false
var _is_attacking := false
var _is_moving = false

var step_counter = 0
const STEPS_TO_TRIGGER = 2

@onready var slime := get_tree().get_first_node_in_group("player")
@onready var movement_map :=  $"../../MovementLogicMapLayer"
@onready var visual_map = $"../../TileMapLayer"
var pathfinder: Pathfinder

signal tile_triggered(tile: TileBase, action: String, data: Dictionary)

func _ready():
	super._ready()
	vita = 3
	posizione_tile = Vector2i(-1, -8)
	snap_to_tile_center(posizione_tile)
	_reset_breath_timer()

func _process(delta: float) -> void:
	_breath_timer += delta
	if _breath_timer >= _waiting_time and !_is_attacking:
		breath()

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

### ------- Turn ------- ###

func take_turn():
	if _is_attacking or _is_moving:
		return
	_pathfind_and_move()

func _pathfind_and_move():
	if _is_moving:
		return

	if is_adjacent_to_slime():
		slime.lock_input()
		_is_attacking = true
		animation.play("ATTACK")
		await animation.animation_finished
		attack()
	else:
		var next_tile = find_next_tile()
		if next_tile != posizione_tile:
			await move_to(next_tile)
	
	_apply_tile_effect_here()

### ------- Move ------- ###

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
	await _animate_move_to(next_tile)
	posizione_tile = next_tile
	snap_to_tile_center(next_tile)

func _animate_move_to(tile: Vector2i) -> void:
	_is_moving = true

	#animation.play("MOVE")
	var target_pos = tilemap.map_to_local(tile) - $Center.position

	# movimento smooth (0.2s)
	var tween = create_tween()
	tween.tween_property(self, "global_position", target_pos, 0.2)

	await tween.finished

	animation.play("IDLE")
	_is_moving = false

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
	if level_logic:
		level_logic.apply_tile_effect_to_enemy(self, posizione_tile)

### ------- Attack ------- ###

func attack():
	emit_signal("tile_triggered", self, "death", {"death_type": GameManager.Death.ENEMY})
	_is_attacking = false

### ------- Breath ------- ###

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
