# Scripts/Backgrounds/SkullBackgroundGenerator.gd
extends IBackgroundGenerator
class_name SkullBackgroundGenerator

# --- Configurazioni ---
const BG_COLOR: Color = Color(0.184, 0.227, 0.184, 1) # #2f3a2f
const TEXTURE_PATH: String = "res://Assets/Sprites/UI/background_set.png"
const REGION_RECT: Rect2 = Rect2(Vector2(36, 0), Vector2(18, 18))
const BASE_TILE_SIZE: Vector2 = Vector2(18, 18)

# Animazione
const ANIMATION_SPEED: float = 4.0
const SCALE_MIN: float = 3.0
const SCALE_RANGE: float = 2.0
const WAVE_OFFSET: float = 0.9

# -------------------------------
# Colore sfondo
# -------------------------------
func get_bg_color() -> Color:
	return BG_COLOR

# -------------------------------
# Creazione pannelli
# -------------------------------
func create_panel(panel_size: Vector2) -> Node:
	var skull_sprite := Sprite2D.new()
	skull_sprite.texture = preload(TEXTURE_PATH)
	skull_sprite.region_enabled = true
	skull_sprite.region_rect = REGION_RECT
	skull_sprite.scale = panel_size / BASE_TILE_SIZE
	skull_sprite.centered = true
	return skull_sprite

# -------------------------------
# Aggiornamento pannelli
# -------------------------------
func update_panel(node: Node, _row: int, _col: int, elapsed_time: float, _delta: float) -> void:
	if node is Node2D:
		node.scale = Vector2.ONE * _calculate_scale(elapsed_time)

func _calculate_scale(elapsed_time: float) -> float:
	var wave := sin(elapsed_time * ANIMATION_SPEED) * 0.5 + WAVE_OFFSET
	return SCALE_MIN + SCALE_RANGE * wave
