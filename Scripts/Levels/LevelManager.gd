# -- LevelManager.gd -- #
extends Node2D

@onready var player = $YSort/Player
@onready var hud_manager: LevelHUDManager = $CanvasHUD/HUD
@onready var pickup_layer: Node2D = $YSort/PickupMapLayer
@onready var pause_menu: Control = $CanvasHUD/Pause
@onready var dialog_interface: DialogueInterface = $CanvasHUD/DialogInterface
@onready var level_logic: Node = $LevelLogic
@onready var dark_overlay = $DarkOverlay
@onready var background_manager: BackgroundManager = $BackgroundManager

enum VictoryMode {
	TILES,
	BOSS,
	CUSTOM
}

var victory_mode: VictoryMode = VictoryMode.TILES

var steps := 0
var level_time := 0.0
var tile_manager
var exit_position: Vector2 = Vector2.ZERO
var all_tiles_active := false
var boss_defeated := false
var time_running := true
var is_boss_level := false


func _ready():
	GameLogger.info("Inizio livello %d" % GameManager.current_level)
	$MovementLogicMapLayer.visible = false
	$MovementLogicMapLayer.add_to_group("movement_logic")
	pause_menu.visible = false
	pause_menu.hide()
	
	dark_overlay.visible = GameManager.get_level_range_for_location(GameManager.Location.DUNGEON).has(GameManager.current_level)
	
	setup_background()
	setup_hud()
	
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
	
	var pickups = get_tree().get_nodes_in_group("pickups")

	for pickup in pickups:
		var tile_coords = tile_manager.get_coords_from_global_position(pickup.global_position)
		var tile_pos = pickup_layer.map_to_local(tile_coords)
		pickup.snap_to_tile_center(tile_pos, tile_coords)

func _process(delta):
	if time_running:
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

func setup_hud():
	hud_manager.setup_base_level()
	
	if is_boss_level:
		var boss = get_tree().get_first_node_in_group("enemy")
		if boss:
			boss.defeated.connect(on_boss_defeated)
			var boss_hp = boss.vita if boss else 3
			hud_manager.setup_boss_level(boss_hp)

func toggle_pause():
	get_tree().paused = not get_tree().paused
	pause_menu.visible = get_tree().paused
	
	if pause_menu.visible:
		pause_menu._on_pause_visible()

func _on_all_tiles_activated():
	GameLogger.info("Tutte le tile attivate → Apertura porte!")
	
	all_tiles_active = true
	
	var porte = get_tree().get_nodes_in_group("porte")
	for porta in porte:
		if porta.has_method("open"):
			porta.open()
	
	for tile in get_tree().get_nodes_in_group("activatables"):
		tile.locked = true
	
	check_victory_condition()

func _on_steps_changed(new_count: int) -> void:
	steps = new_count
	hud_manager.update_steps(steps)
	level_logic.on_player_step(steps)
	check_victory()

func _on_player_died():
	await get_tree().create_timer(1.5).timeout
	GameManager.current_steps = steps
	GameManager.current_time = level_time
	GameManager.end_level(false)
	GameManager.change_scene_to_defeat()

# ================================================================
# ========= Funzione di controllo condizione di vittoria =========
# ================================================================
func on_boss_defeated():
	boss_defeated = true
	_on_boss_defeated_custom()
	check_victory_condition()

func _on_boss_defeated_custom():
	pass

func check_victory_condition():
	match victory_mode:
		VictoryMode.TILES:
			if all_tiles_active:
				_open_exit()
		
		VictoryMode.BOSS:
			if boss_defeated:
				_open_exit()
		
		VictoryMode.CUSTOM:
			GameLogger.info("Controllo personalizzato da sottoclasse")

func _open_exit():
	GameLogger.info("Uscita sbloccata!")
	
	# Livelli senza uscita fisica
	if exit_position == Vector2.ZERO:
		player.on_player_won()
		return
	
	tile_manager.activate_exit_particles(exit_position)

func check_victory():
	if exit_position == Vector2.ZERO:
		return
	
	if not all_tiles_active and victory_mode == VictoryMode.TILES:
		return
	
	if not boss_defeated and victory_mode == VictoryMode.BOSS:
		return
	
	var player_tile = tile_manager.get_coords_from_global_position(player.position)
	var exit_tile = Vector2i(exit_position)
	
	if player_tile == exit_tile:
		player.on_player_won()

func _on_player_won():
	GameManager.current_steps = steps
	GameManager.current_time = level_time
	GameManager.total_steps += steps
	GameManager.total_time += level_time
	
	await player.on_finish_level()
	
	GameLogger.info("Completato livello %d in %d secondi con %d passi" % [GameManager.current_level, level_time, steps])
	GameManager.end_level(true)
	#await get_tree().create_timer(1).timeout
	GameManager.change_scene_to_victory()

# -- UTILS -- #
func set_current_level_number(current_level: int):
	GameManager.current_level = current_level
