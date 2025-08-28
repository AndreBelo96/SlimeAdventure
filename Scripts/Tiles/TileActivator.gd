extends "res://Scripts/Tiles/TileBase.gd"

signal tile_state_changed

var locked := false

@onready var center_marker: Marker2D = $Center
@onready var animation_player: AnimatedSprite2D = $AnimatedTile
@onready var particles := $GlowParticles

func _ready():
	super._ready()
	add_to_group("activatables")
	set_region_from_coords(0, GameManager.get_tileset_row_for_level())
	sprite.texture = atlas_texture
	var animation_row = GameManager.get_tileset_row_for_level()
	var frames = _create_animations(animation_row)
	animation_player.frames = frames

func _create_animations(row: int):
	var frames = SpriteFrames.new()

	frames.add_animation("Activate")
	frames.set_animation_speed("Activate", 30)
	frames.set_animation_loop("Activate", false)
	for col in range(0, 7):
		var tex = AtlasTexture.new()
		tex.atlas = TILESET
		tex.region = Rect2(Vector2(col * 64, row * 32), Vector2(64, 32))
		frames.add_frame("Activate", tex)

	# Deactivate animation (frames da colonna 7 a 0)
	frames.add_animation("Deactivate")
	frames.set_animation_speed("Deactivate", 30)
	frames.set_animation_loop("Deactivate", false)
	for x in range(6, -1, -1):
		var tex = AtlasTexture.new()
		tex.atlas = TILESET
		tex.region = Rect2(Vector2(x * 64, row * 32), Vector2(64, 32))
		frames.add_frame("Deactivate", tex)

	return frames

func on_player_enter():
	
	if locked:
		return
	
	is_active = !is_active
	if is_active:
		animation_player.play("Activate")
		SoundManager.play_sfx("res://Assets/Audio/AccendeTile.wav")
		print("Tile attivato!")
	else:
		animation_player.play("Deactivate")
		SoundManager.play_sfx("res://Assets/Audio/SpegneTile.wav")
		print("Tile disattivato!")
	
	emit_signal("tile_triggered", self, "activate", {"is_active": is_active})
	emit_signal("tile_state_changed")

func is_activated() -> bool:
	return is_active

func _on_animated_tile_animation_finished() -> void:
	var current_anim = animation_player.animation

	if current_anim == "Activate":
		# Glow blu
		animation_player.modulate = Color(2, 2, 2)
		particles.emitting = true;
		await get_tree().create_timer(0.2).timeout
		particles.emitting = false;
		animation_player.modulate = Color(1, 1, 1)
	elif current_anim == "Deactivate":
		# Glow rosso/arancione
		animation_player.modulate = Color(2, 0.6, 0.3)
		await get_tree().create_timer(0.3).timeout
		animation_player.modulate = Color(1, 1, 1) 
