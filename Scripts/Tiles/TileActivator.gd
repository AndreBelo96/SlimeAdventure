extends "res://Scripts/Tiles/TileBase.gd"

signal tile_state_changed

var locked := false

@onready var center_marker: Marker2D = $Center
@onready var animation_player: AnimatedSprite2D = $AnimatedTile
@onready var particles := $GlowParticles

func _ready():
	super._ready()
	add_to_group("activatables")
	set_region_from_coords(0, LocationManager.get_tileset_row_for_level())
	sprite.texture = atlas_texture
	var animation_row = LocationManager.get_tileset_row_for_level()
	var frames = _create_animations(animation_row)
	animation_player.frames = frames

func _create_animations(row: int) -> SpriteFrames:
	var frames = SpriteFrames.new()
	_add_frame_animation(frames, "Activate", row, range(0, 7))
	_add_frame_animation(frames, "Deactivate", row, range(6, -1, -1))
	return frames

func _add_frame_animation(frames: SpriteFrames, anim_name: String, row: int, columns) -> void:
	frames.add_animation(anim_name)
	frames.set_animation_speed(anim_name, 30)
	frames.set_animation_loop(anim_name, false)
	for col in columns:
		var tex := AtlasTexture.new()
		tex.atlas = TILESET
		tex.region = Rect2(Vector2((col * 66) + 1, (row * 50) + 1), Vector2(64, 48))
		frames.add_frame(anim_name, tex)

func on_player_enter():
	
	if locked:
		return
	
	is_active = !is_active
	if is_active:
		animation_player.play("Activate")
		SoundManager.play_sfx("res://Assets/Audio/Sound/AccendeTile.wav")
	else:
		animation_player.play("Deactivate")
		SoundManager.play_sfx("res://Assets/Audio/Sound/SpegneTile.wav")
	
	emit_signal("tile_state_changed")

func is_activated() -> bool:
	return is_active

func _on_animated_tile_animation_finished() -> void:
	var current_anim = animation_player.animation

	if current_anim == "Activate":
		particles.emitting = true
		await VisualEffects.flash(animation_player)
		particles.emitting = false
	elif current_anim == "Deactivate":
		await VisualEffects.flash(animation_player, 0.3, Color(2, 0.6, 0.3))
