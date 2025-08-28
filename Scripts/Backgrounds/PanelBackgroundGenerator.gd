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

func update_panel(_node: Node, _row: int, _col: int, _elapsed_time: float, _delta: float) -> void:
	if _node is Control:
		var scale_value = 0.3 + 0.8 * (sin(_elapsed_time * 2.0) * 0.5 + 0.5)
		_node.scale = Vector2.ONE * scale_value
