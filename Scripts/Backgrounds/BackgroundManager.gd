# -- BackgroundManager.gd -- #
extends Node2D
class_name BackgroundManager

# --- Configurazioni ---
@export var move_speed := Vector2(40, 40)
@export var panel_size := Vector2(50, 50)
@export var panel_count := 5
@export var row_count := 5
@export var panel_generator: IBackgroundGenerator

# --- Riferimenti scene ---
@onready var panel_container := $CanvasLayer/Node
@onready var vignette: Control = $CanvasLayer/VignetteRect
@onready var dark_overlay = $CanvasLayer/DarkOverlay
@onready var bg_color_rect: ColorRect = $CanvasLayer/BgColor

# --- Stato interno ---
var screen_size := Vector2.ZERO
var spacing_x := 0.0
var spacing_y := 0.0
var panels_data := []
var scroll_offset := Vector2.ZERO
var elapsed_time := 0.0

# -------------------------------
# Lifecycle
# -------------------------------
func _ready() -> void:
	screen_size = DisplayServer.window_get_size()
	spacing_x = screen_size.x / panel_count
	spacing_y = screen_size.y / row_count

func _process(delta: float) -> void:
	elapsed_time += delta
	scroll_offset += move_speed * delta
	_update_panels(delta)

# -------------------------------
# Public API
# -------------------------------
func initialize(generator: IBackgroundGenerator):
	if not generator:
		push_error("Nessun generatore di pannelli assegnato")
		return
	
	panel_generator = generator
	_apply_level_colors()
	_setup_vignette_overlay()
	_create_panels()

# -------------------------------
# Setup helpers
# -------------------------------
func _apply_level_colors() -> void:
	dark_overlay.color = GameManager.get_dark_overlay_for_level()
	bg_color_rect.color = panel_generator.get_bg_color()

func _setup_vignette_overlay() -> void:
	vignette.texture = preload("res://Assets/Sprites/UI/vignette.png") 
	vignette.modulate = Color(1, 1, 1, 0.5) 
	vignette.anchor_right = 1.0 
	vignette.anchor_bottom = 1.0 
	vignette.size_flags_horizontal = Control.SIZE_FILL 
	vignette.size_flags_vertical = Control.SIZE_FILL

# -------------------------------
# Pannelli
# -------------------------------
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
		_update_panel_position(data)
		_update_panel_content(data, delta)

func _update_panel_position(data: Dictionary) -> void:
	var row = data["row"]
	var col = data["col"]

	var x = col * spacing_x + scroll_offset.x
	var y = row * spacing_y + scroll_offset.y

	col = _wrap_coordinate(col, spacing_x, scroll_offset.x, screen_size.x, panel_count)
	row = _wrap_coordinate(row, spacing_y, scroll_offset.y, screen_size.y, row_count)

	if data["base_row"] % 2 == 1:
		x += spacing_x / 2

	data["row"] = row
	data["col"] = col

	var node = data["node"]
	if node is Node2D or node is Control:
		node.position = Vector2(x, y)

func _wrap_coordinate(index: int, spacing: float, offset: float, max_size: float, max_count: int) -> int:
	while index * spacing + offset + spacing < 0:
		index += max_count + 1
	while index * spacing + offset > max_size:
		index -= max_count + 1
	return index

func _update_panel_content(data: Dictionary, delta: float) -> void:
	panel_generator.update_panel(
		data["node"], 
		data["row"], 
		data["col"], 
		elapsed_time, 
		delta
	)
