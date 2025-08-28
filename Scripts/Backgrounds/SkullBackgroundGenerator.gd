# Scripts/Backgrounds/SkullBackgroundGenerator.gd
extends IBackgroundGenerator

class_name SkullBackgroundGenerator

func get_bg_color() -> Color:
	return  Color.html("#2f3a2f")

func create_panel(panel_size: Vector2) -> Node:
	var skull_sprite := Sprite2D.new()
	skull_sprite.texture = preload("res://Assets/Sprites/UI/background_set.png")
	skull_sprite.region_enabled = true
	skull_sprite.region_rect = Rect2(Vector2(36, 0), Vector2(18, 18))
	skull_sprite.scale = panel_size / Vector2(18, 18)
	skull_sprite.centered = true
	return skull_sprite

func update_panel(_node: Node, _row: int, _col: int, _elapsed_time: float, _delta: float) -> void:
	if _node is Node2D:
		var scale_value = 3 + 2 * (sin(_elapsed_time * 4.0) * 0.5 + 0.9)
		_node.scale = Vector2.ONE * scale_value
