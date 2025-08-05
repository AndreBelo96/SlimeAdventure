extends Node2D

@onready var hud = $CanvasHUD/HUD
@onready var player = $YSort/Player
@onready var background_root =$BackgroundRoot
@onready var pause_menu = $CanvasHUD/Pause
@onready var tile_label = $CanvasHUD/HUD/Base/Control/TileToActive
@onready var dialog_interface = $CanvasHUD/DialogInterface
@onready var dark_overlay = $DarkOverlay

enum OggettiDecorativi {
	PORTA_CELLA,
	GABBIA
}

const OGGETTI_REGIONI = {
	OggettiDecorativi.PORTA_CELLA: Rect2i(0, 0, 32, 72),
	OggettiDecorativi.GABBIA: Rect2i(64, 0, 64, 64)
}

var steps := 0
var level_time := 0.0
var texture_atlas = preload("res://Assets/Sprites/Decorations/set_decorazioni.png")

func _ready():
	pause_menu.visible = false
	if not GameManager.get_level_range_for_location(GameManager.Location.DUNGEON).has(GameManager.current_level):
		dark_overlay.visible = false
	
	pause_menu.hide()
	player.player_died.connect(_on_player_died)
	player.player_won.connect(_on_player_won)
	player.steps_changed.connect(_on_steps_changed)
	
	await get_tree().process_frame
	
	# Connessione dei segnali delle tile attivabili
	for child in $TileMapLayer.get_children():
		if child.has_method("is_activated"):
			if child.has_signal("tile_state_changed"):
				child.connect("tile_state_changed", Callable(self, "update_tile_label"))
	call_deferred("update_tile_label")
	call_deferred("assegna_chiavi_da_tilemap")
	call_deferred("connect_interruttori")

func _process(delta):
	level_time += delta
	hud.get_node("TimeLabel").text = "Tempo: " + str(int(level_time)) + "s"

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):  # ESC
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		toggle_pause()

func toggle_pause():
	get_tree().paused = not get_tree().paused
	pause_menu.visible = get_tree().paused

func set_background(scene_path: String):
	clear_children(background_root)
	var bg_scene = load(scene_path).instantiate()
	background_root.add_child(bg_scene)

func set_current_level_number(current_level: int):
	GameManager.current_level = current_level

func clear_children(node: Node):
	for child in node.get_children():
		child.queue_free()

func _on_player_died():
	print("MORTE!")
	await get_tree().create_timer(1.5).timeout
	show_defeat_screen()

func _on_player_won():
	print("VITTORIA!")
	
	# Salva tempo e passi nel GameManager
	GameManager.current_steps = steps
	GameManager.current_time = level_time
	
	GameManager.total_steps += steps
	GameManager.total_time += level_time
	
	GameManager.save_progress(GameManager.current_level, steps, level_time)
	
	await get_tree().create_timer(1).timeout
	show_victory_screen()

func _on_steps_changed(new_count: int) -> void:
	hud.get_node("Base").get_node("StepsLabel").text = "Passi: %d" % new_count
	steps = new_count

func spanw_ogg_decorativo(tipo: OggettiDecorativi, tile_pos: Vector2i, offset := Vector2.ZERO):
	
	match tipo:
		OggettiDecorativi.PORTA_CELLA:
			var porta_scene = preload("res://Scenes/Decorations/PortaCella.tscn").instantiate()
			porta_scene.position = tile_to_world(tile_pos) + offset
			$YSort/OggettiDecorativi.add_child(porta_scene)
		_:
			var sprite = Sprite2D.new()
			sprite.centered = true
			var atlas = AtlasTexture.new()
			atlas.atlas = texture_atlas
			atlas.region = OGGETTI_REGIONI[tipo]
			sprite.texture = atlas
			var world_pos = tile_to_world(tile_pos) + offset
			sprite.position = world_pos
			sprite.y_sort_enabled = true
			$YSort/OggettiDecorativi.add_child(sprite)

func tile_to_world(tile_pos: Vector2i) -> Vector2:
	var tile_width := 64.0
	var tile_height := 24.0
	
	return Vector2(
		int((tile_pos.x - tile_pos.y) * (tile_width / 2)),
		int((tile_pos.x + tile_pos.y) * (tile_height / 2))
	)

func assegna_chiavi_da_tilemap():
	var placeholder_map := $LogicMapLayer
	var scene_layer     := $TileMapLayer
	var area = placeholder_map.get_used_rect()

	print("--- Inizio assegnazione chiavi ---")
	for y in range(area.position.y, area.end.y):
		for x in range(area.position.x, area.end.x):
			var cell = Vector2i(x, y)
			var tile_id = placeholder_map.get_cell_source_id(cell)
			if tile_id < 0:
				continue
			var chiave = cell.get_custom_data("chiave")
			print("Cella:", cell, "→ tile_id =", tile_id, "→ chiave =", chiave)

			for nodo in scene_layer.get_children():
				# converto pixel → cella
				var nodo_cell = scene_layer.local_to_map(nodo.position)
				print(" ├ Nodo:", nodo.name, "@ pixel", nodo.position, 
				"→ cella", nodo_cell,
				"in_group(interruttori):", nodo.is_in_group("interruttori"),
				"in_group(spine):", nodo.is_in_group("spine"))

				if nodo_cell == cell and (nodo.is_in_group("interruttori") or nodo.is_in_group("spine")):
					print(" └>> Match! assegno chiave", chiave, "a", nodo.name)
					nodo.chiave = chiave

	print("--- Fine assegnazione chiavi ---")

func connect_interruttori():
	for child in $TileMapLayer.get_children():
		if child.is_in_group("interruttori"):
			child.interruttore_premuto.connect(_on_interruttore_premuto)

func _on_interruttore_premuto(chiave: String):
	for spina in $TileMapLayer.get_children():
		if spina.is_in_group("spine") and spina.chiave == chiave:
			spina.disattiva()

func show_defeat_screen():
	get_tree().change_scene_to_file("res://Scenes/UI/Defeat.tscn")

func show_victory_screen():
	get_tree().change_scene_to_file("res://Scenes/UI/Victory.tscn")

func update_tile_label():
	var total = 0
	var activated = 0
	for child in $TileMapLayer.get_children():
		if child.has_method("is_activated"):
			total += 1
			if child.is_activated():
				activated += 1
	tile_label.text = "%d / %d" % [activated, total]
