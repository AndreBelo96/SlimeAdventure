extends "res://Scripts/Tiles/TileBase.gd"

@onready var animation = $AnimatedTile

var is_raised = false
var step_counter = 0
const STEPS_TO_TRIGGER = 3

func _ready():
	super._ready()
	set_region_from_coords(LocationManager.SPIKE_STEP_TILE_POSITION, LocationManager.get_tileset_row_for_level())
	sprite.texture = atlas_texture

func setup_level_logic(_level_logic) -> void:
	_level_logic.global_step.connect(_on_global_step)

func _on_global_step(step_count: int):
	if step_count % STEPS_TO_TRIGGER == 0:
		_raise_spikes()
	elif is_raised:
		_lower_spikes()

func _raise_spikes():
	is_raised = true
	SoundManager.play_sfx(AudioPresets.ACTIVATE_SPINE, -20)
	weight = 8
	animation.play("UP")

func _lower_spikes():
	is_raised = false
	SoundManager.play_sfx(AudioPresets.DEACTIVATE_SPINE, -20)
	weight = 1
	animation.play("DOWN")

func on_player_enter():
	if (is_raised):
		emit_signal("tile_triggered", self, "death", {"death_type": DeathType.Type.SPIKES})

func on_enemy_enter(_enemy: EnemyBase):
	if (is_raised):
		_enemy.receive_hit("damage")
