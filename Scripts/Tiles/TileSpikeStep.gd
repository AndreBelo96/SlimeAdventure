extends "res://Scripts/Tiles/TileBase.gd"

@onready var animation = $AnimatedTile
@onready var player := get_tree().get_first_node_in_group("player")

var isUp = false
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
	elif isUp:
		_lower_spikes()

func _raise_spikes():
	isUp = true
	SoundManager.play_sfx("res://Assets/Audio/Sound/Spike/ActivateSpine.wav", -20)
	peso = 8
	_play_locked("UP")

func _lower_spikes():
	isUp = false
	SoundManager.play_sfx("res://Assets/Audio/Sound/Spike/DeactivateSpine.wav", -20)
	peso = 1
	_play_locked("DOWN")

func _play_locked(anim_name: String) -> void:
	if player:
		player.lock_input()

	animation.play(anim_name)
	await animation.animation_finished

	if player:
		player.unlock_input()

func on_player_enter():
	if (isUp):
		emit_signal("tile_triggered", self, "death", {"death_type": DeathType.Type.SPIKES})

func on_enemy_enter(_enemy: EnemyBase):
	if (isUp):
		_enemy.receive_hit("damage")
