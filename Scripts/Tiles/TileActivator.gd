extends "res://Scripts/Tiles/TileBase.gd"

signal tile_state_changed

var locked := false

@onready var particles := $GlowParticles

func _ready():
	super._ready()
	add_to_group("activatables")
	animated_tile.animation_finished.connect(_on_animated_tile_animation_finished)

func _atlas_id() -> String:
	return "activator"

func _start_animation() -> StringName:
	return &"Activate"

func on_player_enter():
	
	if locked:
		return
	
	is_active = !is_active
	if is_active:
		animated_tile.play("Activate")
		SoundManager.play_sfx("res://Assets/Audio/Sound/AccendeTile.wav")
	else:
		animated_tile.play("Deactivate")
		SoundManager.play_sfx("res://Assets/Audio/Sound/SpegneTile.wav")
	
	emit_signal("tile_state_changed")

func is_activated() -> bool:
	return is_active

func _on_animated_tile_animation_finished() -> void:
	var current_anim = animated_tile.animation

	if current_anim == "Activate":
		particles.emitting = true
		await VisualEffects.flash(animated_tile)
		particles.emitting = false
	elif current_anim == "Deactivate":
		await VisualEffects.flash(animated_tile, 0.3, Color(2, 0.6, 0.3))
