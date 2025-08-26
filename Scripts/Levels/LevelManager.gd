# -- LevelManager.gd -- #
extends Node2D

@onready var player = $YSort/Player
@onready var hud_manager: LevelHUDManager = $CanvasHUD/HUD
@onready var pause_menu: Control = $CanvasHUD/Pause
@onready var dialog_interface: DialogueInterface = $CanvasHUD/DialogInterface
@onready var dark_overlay = $DarkOverlay
@onready var tile_label = $CanvasHUD/HUD/Base/Control/TileToActive
@onready var background_manager: BackgroundManager = $BackgroundManager

signal signal_victory

var steps := 0
var level_time := 0.0
var tile_manager
var exit_position: Vector2 = Vector2.ZERO

func _ready():
	pause_menu.visible = false
	pause_menu.hide()
	
	dark_overlay.visible = GameManager.get_level_range_for_location(GameManager.Location.DUNGEON).has(GameManager.current_level)
	
	setup_background()
	
	player.connect("player_won", Callable(self, "_on_player_won"))
	player.connect("steps_changed", Callable(self, "_on_steps_changed"))
	player.connect("player_died", Callable(self, "_on_player_died"))
	
	await get_tree().process_frame
	
	tile_manager = LevelTileManager.new()
	tile_manager.tile_layer = $TileMapLayer
	tile_manager.logic_map = $LogicMapLayer
	add_child(tile_manager)
	tile_manager.all_tiles_activated.connect(_on_all_tiles_activated)
	tile_manager.tile_progress_changed.connect(hud_manager.update_tile_label)
	
	tile_manager.initialize()
	exit_position = tile_manager.get_exit_position()

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
	print("Tutte le tile attivate → Apro tutte le porte!")
	
	var porte = get_tree().get_nodes_in_group("porte")
	for porta in porte:
		if porta.has_method("open"):
			porta.open()
	
	for tile in get_tree().get_nodes_in_group("activatables"):
		tile.locked = true
	
	if exit_position == Vector2.ZERO:
		player.on_player_won()
	else:
		tile_manager.activate_exit_particles(exit_position)

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
	emit_signal("signal_victory")

# -- UTILS -- #
func set_current_level_number(current_level: int):
	GameManager.current_level = current_level
