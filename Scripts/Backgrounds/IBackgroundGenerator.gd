# Scripts/Backgrounds/IBackgroundGenerator.gd
extends Resource
class_name IBackgroundGenerator

const DEFAULT_BG_COLOR: Color = Color(0.1176, 0.1176, 0.1843, 1.0) #1e1e2f

func get_bg_color() -> Color:
	push_warning("Usato colore di default: %s (nessun generatore specificato)" % DEFAULT_BG_COLOR.to_html())
	return DEFAULT_BG_COLOR

func create_panel(_panel_size: Vector2) -> Node:
	push_error("create_panel non implementato in %s" % self)
	return null

func update_panel(_node: Node, _row: int, _col: int, _elapsed_time: float, _delta: float) -> void:
	push_error("update_panel non implementato in %s" % self)
