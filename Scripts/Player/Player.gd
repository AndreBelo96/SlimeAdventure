extends Node2D

const DeathType = preload("res://Scripts/Player/DeathType.gd").DeathType

signal player_died(death_type: int)
signal player_won
signal steps_changed(new_count: int)

@export var tile_map_layer_path: NodePath
@export var pickup_map_layer_path: NodePath
@export var wall_map_layer_path: NodePath
@export var wall_back_map_layer_path: NodePath
@export var doors_map_layer_path: NodePath
@export var npc_map_layer_path: NodePath
@export var point_light_path: NodePath
@export var move_duration := 0.4

var steps: int = 0
var input_enabled := true

@onready var tile_map_layer: Node = get_node(tile_map_layer_path)
@onready var pickup_map_layer: Node = get_node(pickup_map_layer_path)
@onready var wall_map_layer: Node = get_node(wall_map_layer_path)
@onready var wall_back_map_layer: Node = get_node(wall_back_map_layer_path)
@onready var doors_map_layer: Node = get_node(doors_map_layer_path)
@onready var npc_map_layer: Node = get_node(npc_map_layer_path)
@onready var point_light: PointLight2D = get_node(point_light_path)

@onready var input_handler = PlayerInput.new()
@onready var movement_handler = PlayerMovement.new()
@onready var interaction_handler = PlayerInteraction.new()
@onready var animation_handler = PlayerAnimation.new()
@onready var light_handler = PlayerLight.new()

var can_move := true

func _ready():
	# Verifica che i nodi siano assegnati
	assert(tile_map_layer, "tile_map_layer non assegnato nel Player")
	assert(pickup_map_layer, "pickup_map_layer non assegnato nel Player")
	assert(wall_map_layer, "wall_map_layer non assegnato nel Player")
	assert(wall_back_map_layer, "wall_back_map_layer non assegnato nel Player")
	assert(doors_map_layer, "doors_map_layer non assegnato nel Player")
	assert(npc_map_layer, "npc_map_layer non assegnato nel Player")
	assert(point_light, "point_light non assegnato nel Player")

	movement_handler.setup(self, tile_map_layer, wall_map_layer, wall_back_map_layer, doors_map_layer, npc_map_layer, move_duration)
	interaction_handler.setup(self, tile_map_layer, pickup_map_layer)
	animation_handler.setup($AnimatedSprite2D)
	light_handler.setup(point_light)
	movement_handler.snap_to_tile_center(movement_handler.get_coords_from_global_position_in_layer(global_position, tile_map_layer))
	await get_tree().process_frame
	interaction_handler.check_tile()

func set_lights(isLight):
	light_handler.set_enabled(isLight)

func set_lights_for_duration(duration: float):
	set_lights(true)
	await get_tree().create_timer(duration).timeout
	set_lights(false)

func _unhandled_input(event):
	if not input_enabled or not can_move:
		return

	if movement_handler.is_moving:
		return

	var direction = input_handler.get_direction(event)
	if direction != Vector2i.ZERO:
		movement_handler.move_to(
			movement_handler.grid_position + direction
		)

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
	
	if death_type == DeathType.VOID:
		handle_void_death()
	else:
		animation_handler.play_death(death_type)
	
	GameManager.register_death(death_type)
	emit_signal("player_died")

func handle_void_death():
	z_index = -100

	var tween = create_tween()
	tween.parallel().tween_property(self, "position:y", position.y + 500, 1.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(self, "scale", Vector2(0.3, 0.3), 1.5)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 1.5)
	
	SoundManager.play_sfx("res://Assets/Audio/Fall.wav")
