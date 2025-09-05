extends Node2D

const DEATH = DeathType.Type

signal player_died(death_type: int)
signal player_won
signal steps_changed(new_count: int)

@export var tile_map_layer_path: NodePath
@export var pickup_map_layer_path: NodePath
@export var movement_logic_map_layer_path: NodePath
@export var doors_map_layer_path: NodePath
@export var npc_map_layer_path: NodePath
@export var point_light_path: NodePath
@export var move_duration := 0.4

var steps: int = 0
var input_enabled := true

@onready var tile_map_layer
@onready var pickup_map_layer
@onready var movement_logic_map_layer
@onready var doors_map_layer
@onready var npc_map_layer
@onready var point_light

@onready var input_handler = PlayerInput.new()
@onready var movement_handler = PlayerMovement.new()
@onready var interaction_handler = PlayerInteraction.new()
@onready var animation_handler = PlayerAnimation.new()
@onready var light_handler = PlayerLight.new()

@onready var light_timer = $LightTimer

var can_move := true

func _ready():
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
	interaction_handler.check_tile()
	
	light_timer.timeout.connect(Callable(self, "_on_light_timer_timeout"))

func _set_lights_state(enabled: bool) -> void:
	light_handler.set_enabled(enabled)

func turn_on_lights(duration: float = 0.0) -> void:
	_set_lights_state(true)
	if duration > 0.0:
		light_timer.start(duration)

func _on_light_timer_timeout() -> void:
	_set_lights_state(false)

func _unhandled_input(event):
	if should_ignore_input():
		return
	
	var direction = input_handler.get_direction(event)
	if direction != Vector2i.ZERO:
		movement_handler.move_to( movement_handler.grid_position + direction )

func on_movement_finished():
	steps += 1
	emit_signal("steps_changed", steps)
	interaction_handler.check_tile()
	interaction_handler.check_pickup()

func on_player_won():
	input_enabled = false
	emit_signal("player_won")

func on_player_died(death_type: int):
	input_enabled = false
	print("MORTE! Tipo:", death_type)
	
	if death_type == DEATH.VOID:
		_play_void_death()
	else:
		animation_handler.play_death(death_type)
	GameManager.register_death(death_type)
	emit_signal("player_died")

func _play_void_death():
	z_index = -100

	var tween = create_tween()
	tween.parallel().tween_property(self, "position:y", position.y + 500, 1.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(self, "scale", Vector2(0.3, 0.3), 1.5)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 1.5)
	
	SoundManager.play_sfx("res://Assets/Audio/Fall.wav")
	#sound.volume_db = linear_to_db(0.5)

func should_ignore_input() -> bool:
	return not input_enabled or not can_move or movement_handler.is_moving

func get_required_node(path: NodePath, description: String) -> Node:
	var node = get_node_or_null(path)
	assert(node, "%s non assegnato nel Player" % description)
	return node
