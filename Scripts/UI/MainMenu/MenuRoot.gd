extends Control
class_name MenuRoot
enum PanelState { MAIN, SAVE, LOCATION, LEVEL, OPTION }
@onready var main_panel: MainMenuPanel = $MainMenuPanel
@onready var save_panel: SaveMenuPanel = $SaveMenuPanel
@onready var location_panel: LocationMenuPanel = $LocationMenuPanel
@onready var level_panel: LevelMenuPanel = $LevelMenuPanel
@onready var option_menu: Control = $OptionMenu
var current_state: PanelState = PanelState.MAIN
var _transition_tween: Tween

func _ready() -> void:
	if SoundManager.current_music_path == "" or SoundManager.current_music_path != AudioPresets.MAIN_MENU_MUSIC:
		SoundManager.play_music(AudioPresets.MAIN_MENU_MUSIC)
	main_panel.start_pressed.connect(_on_start_pressed)
	main_panel.option_pressed.connect(_on_option_pressed)
	main_panel.exit_pressed.connect(_on_exit_pressed)
	save_panel.back_pressed.connect(_on_save_back_pressed)
	save_panel.play_pressed.connect(_on_save_play_pressed)
	location_panel.back_pressed.connect(_on_location_back_pressed)
	location_panel.location_chosen.connect(_on_location_chosen)
	level_panel.back_pressed.connect(_on_level_back_pressed)
	await _calibrate_all()
	_show_initial_panel()

func _calibrate_all() -> void:
	main_panel.visible = true
	save_panel.visible = true
	location_panel.visible = true
	option_menu.visible = false
	await get_tree().process_frame
	main_panel.calibrate_positions()
	save_panel.calibrate_positions()
	location_panel.calibrate_positions()
	save_panel.visible = false
	location_panel.visible = false

func _show_initial_panel() -> void:
	if SceneNavigator.menu_state == PanelState.LOCATION:
		_switch_to(PanelState.LOCATION, location_panel, false)
	else:
		_switch_to(PanelState.MAIN, main_panel, false)

func _on_start_pressed() -> void:
	_switch_to(PanelState.SAVE, save_panel)
func _on_option_pressed() -> void:
	_switch_to(PanelState.OPTION, option_menu)
func _on_exit_pressed() -> void:
	get_tree().quit()
func _on_save_back_pressed() -> void:
	_switch_to(PanelState.MAIN, main_panel)
func _on_save_play_pressed() -> void:
	_switch_to(PanelState.LOCATION, location_panel)
func _on_location_back_pressed() -> void:
	_switch_to(PanelState.SAVE, save_panel)
func _on_location_chosen(_location) -> void:
	_switch_to(PanelState.LEVEL, level_panel)
func _on_level_back_pressed() -> void:
	_switch_to(PanelState.LOCATION, location_panel)

func _switch_to(state: PanelState, target: Control, animate: bool = true) -> void:
	current_state = state
	for panel in [main_panel, save_panel, location_panel, level_panel]:
		if panel != target:
			panel.deactivate()
	if animate:
		target.visible = true
		target.modulate.a = 0
	if target.has_method("activate"):
		target.activate()
	if animate:
		await get_tree().process_frame
		await get_tree().process_frame
		await _fade_to(target)
	else:
		if _transition_tween and _transition_tween.is_valid():
			_transition_tween.kill()
		for c in [main_panel, save_panel, location_panel, level_panel, option_menu]:
			c.visible = (c == target)
			c.modulate.a = 1.0

func _fade_to(target: Control) -> void:
	if _transition_tween and _transition_tween.is_valid():
		_transition_tween.kill()
	var containers = [main_panel, save_panel, location_panel, level_panel, option_menu]
	_transition_tween = create_tween()
	for c in containers:
		if c == target:
			_transition_tween.parallel().tween_property(c, "modulate:a", 1, 0.3)
		else:
			_transition_tween.parallel().tween_property(c, "modulate:a", 0, 0.1)
	await _transition_tween.finished
	for c in containers:
		if c != target:
			c.visible = false
