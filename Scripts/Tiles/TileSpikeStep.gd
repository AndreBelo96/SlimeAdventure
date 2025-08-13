extends "res://Scripts/Tiles/TileBase.gd"

@onready var animation = $AnimatedTile #Sarà da modificare come in tile activator

var isUp = false
var step_counter = 0
const STEPS_TO_TRIGGER = 3

func _ready():
	super._ready()
	set_region_from_coords(GameManager.SPIKE_STEP_TILE_POSITION, GameManager.get_tileset_row_for_level())
	sprite.texture = atlas_texture
	# Connetti al segnale steps_changed del player
	var player = get_parent().get_parent().get_node("YSort").get_node("Player")
	player.steps_changed.connect(_on_player_step)

func _on_player_step(step_count: int):
	step_counter = step_count % STEPS_TO_TRIGGER
	if step_counter == 0:
		_raise_spikes()
	elif step_counter == 1 && isUp:
		_lower_spikes()

func _raise_spikes():
	isUp = true
	animation.play("UP")

func _lower_spikes():
	isUp = false
	animation.play("DOWN")

func on_player_enter():
	if (isUp):
		debug_log("Slime colpito dalle punte!")
		emit_signal("tile_triggered", self, "death", {"death_type": GameManager.DeathType.SPIKES})
