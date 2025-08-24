# -- LevelManager.gd -- #
extends Node2D

@onready var player = $YSort/Player
@onready var hud_manager: LevelHUDManager = $CanvasHUD/HUD
@onready var pause_menu: Control = $CanvasHUD/Pause
@onready var dialog_interface: DialogueInterface = $CanvasHUD/DialogInterface
@onready var dark_overlay = $DarkOverlay
@onready var tile_label = $CanvasHUD/HUD/Base/Control/TileToActive
@onready var background_manager: BackgroundManager = $BackgroundManager

var steps := 0
var level_time := 0.0

func _ready():
	pause_menu.visible = false
	pause_menu.hide()
	
	dark_overlay.visible = GameManager.get_level_range_for_location(GameManager.Location.DUNGEON).has(GameManager.current_level)
	
	setup_background()
	
	player.connect("player_won", Callable(self, "_on_player_won"))
	player.connect("steps_changed", Callable(self, "_on_steps_changed"))
	player.connect("player_died", Callable(self, "_on_player_died"))
	
	await get_tree().process_frame
	
	var tile_manager := LevelTileManager.new()
	tile_manager.tile_layer = $TileMapLayer
	tile_manager.logic_map = $LogicMapLayer
	add_child(tile_manager)
	tile_manager.all_tiles_activated.connect(_on_all_tiles_activated)
	tile_manager.tile_progress_changed.connect(hud_manager.update_tile_label)
	
	tile_manager.initialize()

func _process(delta):
	level_time += delta
	hud_manager.update_time(level_time)

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		toggle_pause()

func setup_background(): 
	var generator_instance: IBackgroundGenerator = null 
	match GameManager.get_location_for_level(GameManager.current_level): 
		GameManager.Location.TUTORIAL: 
			generator_instance = PanelBackgroundGenerator.new() 
		GameManager.Location.DUNGEON: 
			generator_instance = SkullBackgroundGenerator.new() 
		_: 
			generator_instance = PanelBackgroundGenerator.new()
	
	background_manager.initialize(generator_instance)

func toggle_pause():
	get_tree().paused = not get_tree().paused
	pause_menu.visible = get_tree().paused

func _on_all_tiles_activated():
	print("Tutte le tile attivate → Apro la porta!")

func _on_player_died():
	print("morte!")
	await get_tree().create_timer(1.5).timeout
	GameManager.current_steps = steps
	GameManager.current_time = level_time
	GameManager.end_level(false)
	GameManager.change_scene_to_defeat()

func _on_player_won():
	print("VITTORIA!")
	GameManager.current_steps = steps
	GameManager.current_time = level_time
	GameManager.total_steps += steps
	GameManager.total_time += level_time
	GameManager.end_level(true)
	
	await get_tree().create_timer(1).timeout
	GameManager.change_scene_to_victory()

func _on_steps_changed(new_count: int) -> void:
	steps = new_count
	hud_manager.update_steps(steps)

# -- UTILS -- #
func set_current_level_number(current_level: int):
	GameManager.current_level = current_level


#func spanw_ogg_decorativo(tipo: OggettiDecorativi, tile_pos: Vector2i, offset := Vector2.ZERO):
	#
	#match tipo:
		#OggettiDecorativi.PORTA_CELLA:
			#var porta_scene = preload("res://Scenes/Decorations/PortaCella.tscn").instantiate()
			#porta_scene.position = (tile_to_world(tile_pos) + offset).floor()
			#$YSort/OggettiDecorativi.add_child(porta_scene)
		#_:
			#var sprite = Sprite2D.new()
			#sprite.centered = true
			#var atlas = AtlasTexture.new()
			#atlas.atlas = texture_atlas
			#atlas.region = OGGETTI_REGIONI[tipo]
			#sprite.texture = atlas
			#var world_pos = (tile_to_world(tile_pos) + offset).floor()
			#sprite.position = world_pos
			#sprite.y_sort_enabled = true
			#$YSort/OggettiDecorativi.add_child(sprite)
