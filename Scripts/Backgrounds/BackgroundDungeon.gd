extends "res://Scripts/Backgrounds/backgroundBase.gd"

func _ready():
	super._ready()
	dark_overlay.color = Color(0.3, 0.3, 0.3, 1)

func _process(delta):
	super._process(delta)

func create_background_image() -> Node:
	var skull_sprite := Sprite2D.new()
	skull_sprite.texture = preload("res://Assets/Sprites/UI/background_set.png")
	
	skull_sprite.region_enabled = true
	skull_sprite.region_rect = Rect2(Vector2(36, 0), Vector2(18, 18))
	
	skull_sprite.scale = panel_size / Vector2(18, 18)
	skull_sprite.centered = true
	return skull_sprite

func update_background_image(node: Node, _row: int, _col: int, _delta: float) -> void:
	if node is Node2D:
		#var phase = float(row + col) * 0.5
		var scale_value = 3 + 2 * (sin(elapsed_time * 4.0) * 0.5 + 0.9)
		node.scale = Vector2.ONE * scale_value
