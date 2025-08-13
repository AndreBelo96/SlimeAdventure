extends Node2D

const DeathType = preload("res://Scripts/Player/DeathType.gd").DeathType

signal player_died(death_type: int)
signal player_won
signal steps_changed(new_count: int)

@export var tile_map_layer_path: NodePath
@export var wall_map_layer_path: NodePath
@export var wall_back_map_layer_path: NodePath
@export var point_light_path: NodePath
@export var move_duration := 0.4

var steps: int = 0
var input_enabled := true

@onready var tile_map_layer: Node = get_node(tile_map_layer_path)
@onready var wall_map_layer: Node = get_node(wall_map_layer_path)
@onready var wall_back_map_layer: Node = get_node(wall_back_map_layer_path)
@onready var point_light: PointLight2D = get_node(point_light_path)

@onready var input_handler = PlayerInput.new()
@onready var movement_handler = PlayerMovement.new()
@onready var interaction_handler = PlayerInteraction.new()
@onready var animation_handler = PlayerAnimation.new()
@onready var light_handler = PlayerLight.new()

func _ready():
	# Verifica che i nodi siano assegnati
	assert(tile_map_layer, "tile_map_layer non assegnato nel Player")
	assert(wall_map_layer, "wall_map_layer non assegnato nel Player")
	assert(wall_back_map_layer, "wall_back_map_layer non assegnato nel Player")
	assert(point_light, "point_light non assegnato nel Player")

	# Setup componenti
	movement_handler.setup(self, tile_map_layer, wall_map_layer, wall_back_map_layer, move_duration)
	interaction_handler.setup(self, tile_map_layer)
	animation_handler.setup($AnimatedSprite2D)
	light_handler.setup(point_light)

	# Attiva luce solo se il livello è buio
	light_handler.set_enabled(GameManager.is_dark_level())

	# Snap iniziale
	movement_handler.snap_to_tile_center(
		movement_handler.get_coords_from_global_position(global_position)
	)
	await get_tree().process_frame
	interaction_handler.check_tile()

func _unhandled_input(event):
	if not input_enabled:
		return

	# Evita che partano due movimenti in contemporanea
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

func on_player_won():
	input_enabled = false
	emit_signal("player_won")

func on_player_died(death_type: int):
	input_enabled = false
	animation_handler.play_death(death_type)
	GameManager.register_death(death_type)
	emit_signal("player_died", death_type)
