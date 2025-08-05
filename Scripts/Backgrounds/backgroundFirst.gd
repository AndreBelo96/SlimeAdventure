extends "res://Scripts/Backgrounds/backgroundBase.gd"

func _ready():
	super._ready()

func _process(delta):
	super._process(delta)


func create_background_image() -> Node:
	var panel := Panel.new()
	panel.custom_minimum_size = panel_size

	var stylebox := StyleBoxFlat.new()
	stylebox.border_color = Color.WHITE
	stylebox.bg_color = Color.TRANSPARENT
	stylebox.set_border_width_all(3)
	panel.add_theme_stylebox_override("panel", stylebox)

	return panel

func update_background_image(node: Node, _row: int, _col: int, _delta: float) -> void:
	if node is Control:
		#var phase = float(row + col) * 0.5
		var scale_value = 0.3 + 0.8 * (sin(elapsed_time * 2.0) * 0.5 + 0.5)
		node.scale = Vector2.ONE * scale_value
