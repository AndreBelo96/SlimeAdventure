# Boss.gd
extends EnemyBase

signal tile_triggered(tile: TileBase, action: String, data: Dictionary)

@export var ceiling_debris_scene: PackedScene
@export var warning_tile_scene: PackedScene
@export var attack_impact_frame := 3
@export var movement_map: TileMapLayer
@export var visual_map: TileMapLayer

var steps_to_trigger = 3
var _warning_pending := false
var _impact_done := false

var boss_attack := BossAttack.new()
var boss_breath := BossBreath.new()

@onready var sprite := $Animation
@onready var slime := get_tree().get_first_node_in_group("player")
@onready var camera := get_viewport().get_camera_2d()

func _ready():
	super._ready()

	turn_behavior = ChaseBehavior.new()
	setup_health(3)
	setup_grid(tilemap, $Center.position, Vector2i(-1, -8), movement_map, visual_map)

	boss_attack.setup(self, warning_tile_scene, ceiling_debris_scene, camera)
	boss_breath.setup(animation)

	if level_logic:
		level_logic.connect("global_step", Callable(self, "_on_global_step"))
		connect("tile_triggered", Callable(level_logic, "_on_tile_triggered"))

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

	if grid_movement.is_adjacent_to(slime.movement_handler.grid_position):
		state = BossState.ATTACKING
	else:
		state = BossState.MOVING

func get_target_position() -> Vector2i:
	return slime.movement_handler.grid_position

func should_move(_step_count: int) -> bool:
	if state == BossState.DEAD:
		return false
	return _step_count % steps_to_trigger == 0

### ------- Move ------- ###

func _start_move():
	action_in_progress = true

	var next_tile = turn_behavior.get_next_tile(self)
	if next_tile != grid_movement.grid_position:
		animation.play("WALK")
		await grid_movement.move_to(next_tile)
		posizione_tile = grid_movement.grid_position

	if _warning_pending:
		boss_attack.show_attack_warning(grid_movement.grid_position, tilemap)
		_warning_pending = false

	action_in_progress = false
	idle_entered = false
	state = BossState.IDLE

	emit_signal("finished_turn", self)

### ------- Take Dmg ------- ###

func damage_animation():
	animation.modulate = Color(2, 2, 2)
	await get_tree().create_timer(0.2).timeout
	animation.modulate = Color(1, 1, 1)

	SoundManager.play_sfx("res://Assets/Audio/Sound/BossColpito.wav")

	var tween := create_tween()
	tween.tween_property(self, "position:y", position.y - 20, 0.15)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)

	tween.tween_property(self, "position:y", position.y, 0.2)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN)

func change_steps():
	steps_to_trigger = max(1, steps_to_trigger - 1)

### ------- Attack ------- ###

func _start_attack():
	action_in_progress = true

	slime.lock_input()
	animation.play("ATTACK")
	await animation.animation_finished
	do_attack()

	action_in_progress = false
	idle_entered = false
	state = BossState.IDLE

func do_attack():
	emit_signal("tile_triggered", self, "death", {"death_type": DeathType.Type.ENEMY})

func _on_attack_impact():
	if camera:
		camera.shake(6.0, 0.25)

	boss_attack.spawn_ceiling_debris()
	$HitParticles.emitting = true

	SoundManager.play_sfx("res://Assets/Audio/Sound/SmashStone.wav")

func _on_global_step(step_count: int) -> void:
	boss_attack.clear_attack_warning()

	if state == BossState.DEAD:
		return

	if (step_count + 1) % steps_to_trigger == 0 and steps_to_trigger > 1:
		boss_attack.show_attack_warning(grid_movement.grid_position, tilemap)

	if steps_to_trigger == 1:
		_warning_pending = true

func _get_attack_tiles() -> Array[Vector2i]:
	return boss_attack.get_attack_tiles(grid_movement.grid_position)

func _on_animation_frame_changed() -> void:
	if sprite.animation != "ATTACK":
		_impact_done = false
		return

	if sprite.frame == attack_impact_frame and not _impact_done:
		_impact_done = true
		_on_attack_impact()

### ------- Breath ------- ###

func breath():
	boss_breath.reset()

func _update_idle(delta: float) -> void:
	if not idle_entered:
		animation.play("IDLE")
		idle_entered = true

	if boss_breath.update(delta):
		idle_entered = false
