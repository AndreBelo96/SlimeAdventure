# Scripts/Backgrounds/IBackgroundGenerator.gd
class_name IBackgroundGenerator
extends Resource

func create_panel(panel_size: Vector2) -> Node:
	push_error("create_panel non implementato")
	return null

func update_panel(node: Node, row: int, col: int, elapsed_time: float, delta: float) -> void:
	push_error("update_panel non implementato")
