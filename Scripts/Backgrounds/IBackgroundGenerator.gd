# Scripts/Backgrounds/IBackgroundGenerator.gd
class_name IBackgroundGenerator
extends Resource

func get_bg_color() -> Color:
	print("Usato colore di default #1e1e2f (nessun generatore specificato)")
	return Color.html("#1e1e2f")

func create_panel(_panel_size: Vector2) -> Node:
	push_error("create_panel non implementato")
	return null

func update_panel(_node: Node, _row: int, _col: int, _elapsed_time: float, _delta: float) -> void:
	push_error("update_panel non implementato")
