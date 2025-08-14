# Scripts/Backgrounds/BackgroundManager.gd
extends Node2D
class_name BackgroundManager

@export var move_speed := Vector2(40, 40)
@export var panel_size := Vector2(50, 50)
@export var panel_count := 5
@export var row_count := 5

@export var panel_generator: IBackgroundGenerator

@onready var panel_container := $CanvasLayer/Node

var screen_size := Vector2.ZERO
var spacing_x := 0.0
var spacing_y := 0.0

var panels_data := []
var scroll_offset := Vector2.ZERO
var elapsed_time := 0.0

func initialize(generator: IBackgroundGenerator):
	if not generator:
		push_error("Nessun generatore di pannelli assegnato")
		return
	panel_generator = generator
	$CanvasLayer/DarkOverlay.color = GameManager.get_dark_overlay_for_level()
	$CanvasLayer/BgColor.color = panel_generator.get_bg_color()
	set_vignette_overlay()
	_create_panels()

func _ready() -> void:
	screen_size = DisplayServer.window_get_size()
	spacing_x = screen_size.x / panel_count
	spacing_y = screen_size.y / row_count

func _process(delta: float) -> void:
	elapsed_time += delta
	scroll_offset += move_speed * delta
	_update_panels(delta)

func _create_panels() -> void:
	for row in range(row_count + 1):
		for col in range(panel_count + 1):
			var panel = panel_generator.create_panel(panel_size)
			if panel:
				panel_container.add_child(panel)
				panels_data.append({
					"node": panel,
					"row": row,
					"col": col,
					"base_row": row
				})

func _update_panels(delta: float) -> void:
	for data in panels_data:
		var node = data["node"]
		var row = data["row"]
		var col = data["col"]

		var x = col * spacing_x + scroll_offset.x
		var y = row * spacing_y + scroll_offset.y

		# Riciclo orizzontale
		while x + spacing_x < 0:
			col += panel_count + 1
			x = col * spacing_x + fposmod(scroll_offset.x, spacing_x)
		while x > screen_size.x:
			col -= panel_count + 1
			x = col * spacing_x + fposmod(scroll_offset.x, spacing_x)

		# Riciclo verticale
		while y + spacing_y < 0:
			row += row_count + 1
			y = row * spacing_y + fposmod(scroll_offset.y, spacing_y)
		while y > screen_size.y:
			row -= row_count + 1
			y = row * spacing_y + fposmod(scroll_offset.y, spacing_y)

		if data["base_row"] % 2 == 1:
			x += spacing_x / 2

		data["row"] = row
		data["col"] = col

		if node is Node2D or node is Control:
			node.position = Vector2(x, y)

		panel_generator.update_panel(node, row, col, elapsed_time, delta)

func set_vignette_overlay(): 
	var vignette = $CanvasLayer/VignetteRect
	vignette.texture = preload("res://Assets/Sprites/UI/vignette.png") 
	vignette.modulate = Color(1, 1, 1, 0.5) 
	vignette.anchor_right = 1.0 
	vignette.anchor_bottom = 1.0 
	vignette.size_flags_horizontal = Control.SIZE_FILL 
	vignette.size_flags_vertical = Control.SIZE_FILL
