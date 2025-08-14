# Scripts/Backgrounds/PanelBackgroundGenerator.gd
extends IBackgroundGenerator

class_name PanelBackgroundGenerator

func create_panel(panel_size: Vector2) -> Node:
	var panel := Panel.new()
	panel.custom_minimum_size = panel_size
	var stylebox := StyleBoxFlat.new()
	stylebox.border_color = Color.WHITE
	stylebox.bg_color = Color.TRANSPARENT
	stylebox.set_border_width_all(3)
	panel.add_theme_stylebox_override("panel", stylebox)
	return panel

func update_panel(node: Node, row: int, col: int, elapsed_time: float, delta: float) -> void:
	if node is Control:
		var scale_value = 0.3 + 0.8 * (sin(elapsed_time * 2.0) * 0.5 + 0.5)
		node.scale = Vector2.ONE * scale_value
