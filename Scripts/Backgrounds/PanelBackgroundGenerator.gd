# Scripts/Backgrounds/PanelBackgroundGenerator.gd
extends IBackgroundGenerator
class_name PanelBackgroundGenerator

# --- Configurazioni ---
const BORDER_COLOR: Color = Color.WHITE
const BACKGROUND_COLOR: Color = Color.TRANSPARENT
const BORDER_WIDTH: int = 3
const ANIMATION_SPEED: float = 2.0
const SCALE_MIN: float = 0.3
const SCALE_MAX: float = 1.1  # 0.3 + 0.8

# -------------------------------
# Creazione pannelli
# -------------------------------
func create_panel(panel_size: Vector2) -> Node:
	var panel := Panel.new()
	panel.custom_minimum_size = panel_size
	var stylebox := _create_panel_stylebox()
	panel.add_theme_stylebox_override("panel", stylebox)
	return panel

func _create_panel_stylebox() -> StyleBoxFlat:
	var stylebox := StyleBoxFlat.new()
	stylebox.border_color = BORDER_COLOR
	stylebox.bg_color = BACKGROUND_COLOR
	stylebox.set_border_width_all(BORDER_WIDTH)
	return stylebox

# -------------------------------
# Aggiornamento pannelli
# -------------------------------
func update_panel(node: Node, _row: int, _col: int, elapsed_time: float, _delta: float) -> void:
	if node is Control:
		node.scale = Vector2.ONE * _calculate_scale(elapsed_time)

func _calculate_scale(elapsed_time: float) -> float:
	var wave := sin(elapsed_time * ANIMATION_SPEED) * 0.5 + 0.5
	return SCALE_MIN + (SCALE_MAX - SCALE_MIN) * wave
