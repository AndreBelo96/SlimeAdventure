# Boss.gd
extends EnemyBase

var min_breath_time := 1.0
var max_breath_time := 3.0
var _breath_timer := 0.0
var _waiting_time := 0.0
var _is_breathing := false
var _is_moving = false

var step_counter = 0
const STEPS_TO_TRIGGER = 2


@onready var slime := get_tree().get_first_node_in_group("player")
@onready var movement_map := get_tree().get_first_node_in_group("movement_logic")
var pathfinder: Pathfinder

signal tile_triggered(tile: TileBase, action: String, data: Dictionary)

func _ready():
	super._ready()
	vita = 3
	posizione_tile = Vector2i(-1, -8)
	snap_to_tile_center(posizione_tile)
	_reset_breath_timer()
	
	slime.steps_changed.connect(_on_slime_step)

func _process(delta: float) -> void:
	_breath_timer += delta
	if _breath_timer >= _waiting_time:
		breath()

func _ensure_pathfinder() -> bool:
	
	if pathfinder != null:
		return true

	if movement_map == null:
		movement_map = get_tree().get_first_node_in_group("movement_logic")

	if movement_map == null:
		return false

	pathfinder = Pathfinder.new(movement_map, GameManager.DIRECTION_BITS)
	return true

func _on_slime_step(step_count: int):
	step_counter = step_count % STEPS_TO_TRIGGER
	
	if step_counter == 0:
		do_turn()

func do_turn():
	if _is_moving:
		return

	if not _ensure_pathfinder():
		return

	if is_adjacent_to_slime():
		attack()
	else:
		var next_tile = find_next_tile()
		await move_to(next_tile)

func find_next_tile() -> Vector2i:
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

	if level_logic:
		level_logic.apply_tile_effect_to_enemy(self, next_tile)

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

func attack():
	print("DAMAGE TO SLIME")
	emit_signal("tile_triggered", self, "death", {
		"death_type": GameManager.Death.ENEMY
	})
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
