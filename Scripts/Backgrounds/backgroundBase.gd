extends Node2D

@export var move_speed := Vector2(40, 40) # movimento diagonale px/sec
@export var panel_size := Vector2(50, 50)
@export var panel_count := 5   # colonne visibili
@export var row_count := 5     # righe visibili
@export var scale_period := 5.0  # tempo in secondi per un ciclo di scala completo (andata e ritorno)

@onready var panel_container := $CanvasLayer/Node

@onready var dark_overlay := $CanvasLayer/DarkOverlay

var screen_size := Vector2.ZERO
var spacing_x := 0.0
var spacing_y := 0.0

var panels_data := []
var scroll_offset := Vector2.ZERO
var elapsed_time := 0.0

func _ready() -> void:
	set_vignette_overlay()
	create_moving_obj()

func _process(delta: float) -> void:
	elapsed_time += delta
	scroll_offset += move_speed * delta

	for data in panels_data:
		var node = data["node"]
		var row = data["row"]
		var col = data["col"]

		# Calcola posizione in base a offset e posizione logica
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

		# Applica lo sfalsamento in base alla riga iniziale
		if data["base_row"] % 2 == 1:
			x += spacing_x / 2
		
		# Salva i nuovi indici logici
		data["row"] = row
		data["col"] = col
		
		# Posizionamento generico
		if node is Node2D:
			node.position = Vector2(x, y)
		elif node is Control:
			node.position  = Vector2(x, y)
		
		# Effetti personalizzati
		update_background_image(node, row, col, delta)

func set_vignette_overlay():
	var vignette = $CanvasLayer/TextureRect
	vignette.texture = preload("res://Assets/Sprites/UI/vignette.png")
	vignette.modulate = Color(1, 1, 1, 0.5)  # regola la trasparenza
	vignette.anchor_right = 1.0
	vignette.anchor_bottom = 1.0
	vignette.size_flags_horizontal = Control.SIZE_FILL
	vignette.size_flags_vertical = Control.SIZE_FILL

func create_moving_obj():
	screen_size = DisplayServer.window_get_size()

	# Calcola la spaziatura in modo che 5 pannelli stiano visibili, ma ne creiamo 6x6 per il riciclo
	spacing_x = screen_size.x / panel_count
	spacing_y = screen_size.y / row_count

	for row in range(row_count + 1):  # +1 per extra riga
		for col in range(panel_count + 1):  # +1 per extra colonna
			var image := create_background_image()
			if image == null:
				continue

			panel_container.add_child(image)

			panels_data.append({
				"node": image,
				"row": row,
				"col": col,
				"base_row": row
			})

func create_background_image() -> Node:
	return null # Override nei figli

func update_background_image(_node: Node, _row: int, _col: int, _delta: float) -> void:
	pass
