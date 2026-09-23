extends Node2D

const DEATH = DeathType.Type
const ARMOR_ABSORBS := [DeathType.Type.SPIKES, DeathType.Type.ENEMY]

signal player_died(death_type: int)
signal player_won
signal steps_changed(new_count: int)
signal move_finished
signal armor_changed(has_armor: bool)

@export var tile_map_layer_path: NodePath
@export var terrain_map_layer_path: NodePath
@export var pickup_map_layer_path: NodePath
@export var movement_logic_map_layer_path: NodePath
@export var doors_map_layer_path: NodePath
@export var npc_map_layer_path: NodePath
@export var point_light_path: NodePath
@export var move_duration := 0.4

var steps: int = 0
var input_enabled := true
var is_cutscene := false 
var grid_position: Vector2i
var _input_lock_count : int = 0
var _terminal_state := false

## -- Armor -- ##
var has_armor := false
var _armor_broken_at_step := -1

@onready var tile_map_layer
@onready var pickup_map_layer
@onready var movement_logic_map_layer
@onready var doors_map_layer
@onready var npc_map_layer
@onready var point_light
@onready var armor_icon = $ArmorIcon   # PLACEHOLDER


@onready var input_handler = PlayerInput.new()
@onready var movement_handler = PlayerMovement.new()
@onready var interaction_handler = PlayerInteraction.new()
@onready var animation_handler = PlayerAnimation.new()
@onready var light_handler = PlayerLight.new()

@onready var light_timer = $LightTimer
@onready var end_level_particles = $CPUParticles2D
@onready var shader_material = $AnimatedSprite2D.material

var can_move := true
var confusion_steps_left := 0


func _ready():
	add_to_group("player")
	PlayerRef.register(self)
	tile_map_layer = get_required_node(tile_map_layer_path, "tile_map_layer")
	pickup_map_layer = get_required_node(pickup_map_layer_path, "pickup_map_layer")
	movement_logic_map_layer = get_required_node(movement_logic_map_layer_path, "movement_logic_map_layer")
	doors_map_layer = get_required_node(doors_map_layer_path, "doors_map_layer")
	npc_map_layer = get_required_node(npc_map_layer_path, "npc_map_layer")
	point_light = get_required_node(point_light_path, "point_light") as PointLight2D
	
	movement_handler.setup(self, tile_map_layer, movement_logic_map_layer, doors_map_layer, npc_map_layer, move_duration)
	interaction_handler.setup(self, tile_map_layer, pickup_map_layer)
	animation_handler.setup($AnimatedSprite2D)
	light_handler.setup(point_light)
	movement_handler.snap_to_tile_center(movement_handler.get_coords_from_global_position_in_layer(global_position, tile_map_layer))
	await get_tree().process_frame
	
	movement_handler.invalidate_indexes()
	grid_position = movement_handler.grid_position
	interaction_handler.check_tile()
	
	light_timer.timeout.connect(Callable(self, "_on_light_timer_timeout"))

func turn_on_lights(duration: float = 0.0) -> void:
	if not light_handler.light:
		return
	light_handler.enable(0.5)
	light_timer.stop()
	light_timer.start(duration)
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.setup_progressbar(duration, duration)

func _process(_delta):
	if light_timer.is_stopped():
		return
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.setup_progressbar(light_timer.time_left, light_timer.wait_time)

func _on_light_timer_timeout() -> void:
	var hud = get_tree().get_first_node_in_group("hud")
	light_handler.disable(1.0)
	light_timer.stop()
	if hud:
		hud.deactivate_progressbar()

func _unhandled_input(event):
	if should_ignore_input():
		return
	
	var direction = input_handler.get_direction(event)
	if direction != Vector2i.ZERO:
		if confusion_steps_left > 0:
			direction = -direction
		movement_handler.move_to( movement_handler.grid_position + direction )

func on_movement_finished():
	grid_position = movement_handler.grid_position
	
	if not is_cutscene:
		_consume_confusion_step()
		steps += 1
		emit_signal("steps_changed", steps)
	
	
	interaction_handler.check_tile()
	interaction_handler.check_pickup()
	
	_check_boss_collision()
	
	can_move = true
	emit_signal("move_finished")

func enter_cutscene() -> void:
	is_cutscene = true
	lock_input()

func exit_cutscene() -> void:
	is_cutscene = false
	unlock_input()

func on_player_won():
	_terminal_state = true
	input_enabled = false
	emit_signal("player_won")

func on_player_died(death_type: int):
	if _try_absorb(death_type):
		return
	_terminal_state = true
	input_enabled = false
	
	if death_type == DEATH.VOID:
		_play_void_death()
	else:
		animation_handler.play_death(death_type)
	LevelStateManager.register_death(death_type)
	emit_signal("player_died")

func _play_void_death():
	z_index = -10

	var tween = create_tween()
	tween.parallel().tween_property(self, "position:y", position.y + 500, 1.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(self, "scale", Vector2(0.3, 0.3), 1.5)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 1.5)
	
	SoundManager.play_sfx("res://Assets/Audio/Sound/Fall.wav", 0.0, 0.06)

func should_ignore_input() -> bool:
	return not input_enabled or not can_move or movement_handler.is_moving

func get_required_node(path: NodePath, description: String) -> Node:
	var node = get_node_or_null(path)
	assert(node, "%s non assegnato nel Player" % description)
	return node

func lock_input() -> void:
	_input_lock_count += 1
	input_enabled = false
	can_move = false

func unlock_input() -> void:
	_input_lock_count = max(_input_lock_count - 1, 0)
	if _input_lock_count == 0 and not _terminal_state:
		input_enabled = true
		can_move = true

func force_move(dir: Vector2i) -> void:
	if movement_handler.is_moving:
		return
	
	can_move = false
	movement_handler.move_to(movement_handler.grid_position + dir)

func _check_boss_collision():
	if not is_inside_tree():
		return
	
	var bosses = get_tree().get_nodes_in_group("enemy")
	for boss in bosses:
		if not boss.is_dead() and boss.grid_position == grid_position:
			_on_player_touch_boss()
			return

func _on_player_touch_boss():
	on_player_died(DeathType.Type.ENEMY)

func on_finish_level():
	var tween = self.create_tween()
	tween.tween_property(shader_material, "shader_parameter/white_value", 0.0, 1)
	end_level_particles.emitting = true
	await tween.finished
	
	var fade_tween = self.create_tween()
	fade_tween.tween_property(shader_material, "shader_parameter/alpha_value", 0.0, 1)
	end_level_particles.emitting = false
	await fade_tween.finished

func reset_end_level_variables():
	shader_material.set_shader_parameter("white_value", 1.0)
	shader_material.set_shader_parameter("alpha_value", 1.0)
	end_level_particles.emitting = false

func _exit_tree():
	PlayerRef.clear(self)

## Confusion ##
func apply_confusion(steps: int) -> void:
	confusion_steps_left = max(confusion_steps_left, steps)
	_update_confusion_visual()

func _consume_confusion_step() -> void:
	if confusion_steps_left > 0:
		confusion_steps_left -= 1
		_update_confusion_visual()

func _update_confusion_visual() -> void:
	# TODO particelle + PLACEHOLDER visivo + schermo?
	$AnimatedSprite2D.modulate = Color(0.8, 0.6, 1.0) if confusion_steps_left > 0 else Color.WHITE

## Armor ##
func give_armor() -> bool:
	if has_armor:
		return false
	has_armor = true
	armor_icon.visible = true
	emit_signal("armor_changed", true)
	return true

func _try_absorb(death_type: int) -> bool:
	if death_type not in ARMOR_ABSORBS:
		return false
	if _armor_broken_at_step == steps:
		return true
	if not has_armor:
		return false

	has_armor = false
	_armor_broken_at_step = steps
	armor_icon.visible = false
	emit_signal("armor_changed", false)
	_play_armor_break()
	return true

func _play_armor_break() -> void:
	SoundManager.play_sfx("res://Assets/Audio/Sound/Bounce.wav")
	var sprite := $AnimatedSprite2D
	var tween := create_tween()
	for i in 3:
		tween.tween_property(sprite, "self_modulate:a", 0.3, 0.08)
		tween.tween_property(sprite, "self_modulate:a", 1.0, 0.08)
