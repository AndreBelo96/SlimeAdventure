extends Control
class_name MenuRoot

enum PanelState { MAIN, SAVE, LOCATION, OPTION }

@onready var main_panel: MainMenuPanel = $MainMenuPanel
@onready var save_panel: SaveMenuPanel = $SaveMenuPanel
@onready var location_panel: LocationMenuPanel = $LocationMenuPanel
@onready var option_menu: Control = $OptionMenu

var current_state: PanelState = PanelState.MAIN

func _ready() -> void:
	if SoundManager.current_music_path == "" or SoundManager.current_music_path != AudioPresets.MAIN_MENU_MUSIC:
		SoundManager.play_music(AudioPresets.MAIN_MENU_MUSIC)
	main_panel.start_pressed.connect(_on_start_pressed)
	main_panel.option_pressed.connect(_on_option_pressed)
	main_panel.exit_pressed.connect(_on_exit_pressed)
	save_panel.back_pressed.connect(_on_save_back_pressed)
	save_panel.play_pressed.connect(_on_save_play_pressed)
	location_panel.back_pressed.connect(_on_location_back_pressed)
	_show_initial_panel()

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

func _switch_to(state: PanelState, target: Control, animate: bool = true) -> void:
	current_state = state

	for panel in [main_panel, save_panel, location_panel]:
		if panel != target:
			panel.deactivate()

	if animate:
		await _fade_to(target)
	else:
		for c in [main_panel, save_panel, location_panel, option_menu]:
			c.visible = (c == target)
			c.modulate.a = 1.0

	if target.has_method("activate"):
		target.activate()

func _fade_to(target: Control) -> void:
	var containers = [main_panel, save_panel, location_panel, option_menu]
	target.visible = true
	target.modulate.a = 0
	
	var tween := create_tween()
	for c in containers:
		if c == target:
			tween.parallel().tween_property(c, "modulate:a", 1, 0.3)
		else:
			tween.parallel().tween_property(c, "modulate:a", 0, 0.1)
	await tween.finished
	for c in containers:
		if c != target:
			c.visible = false
