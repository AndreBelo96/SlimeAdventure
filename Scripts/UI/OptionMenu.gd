extends Control

var panels: Array[PanelContainer] = []

#Buttons
@onready var gameplay_btn: Button = %GameplayBtn
@onready var graphics_btn: Button = %GraphicsBtn
@onready var audio_btn: Button = %AudioBtn
@onready var controls_btn: Button = %ControlsBtn

@onready var master_slider: HSlider = $MarginContainer/HBoxContainer/AudioPanel/MarginContainer/VBoxContainer/VBoxContainer/MasterSlider
@onready var music_slider: HSlider = $MarginContainer/HBoxContainer/AudioPanel/MarginContainer/VBoxContainer/VBoxContainer2/MusicSlider
@onready var sound_slider: HSlider = $MarginContainer/HBoxContainer/AudioPanel/MarginContainer/VBoxContainer/VBoxContainer3/SoundSlider
@onready var environment_slider: HSlider = $MarginContainer/HBoxContainer/AudioPanel/MarginContainer/VBoxContainer/VBoxContainer4/EnvironmentSlider
@onready var difficult_option: OptionButton = $MarginContainer/HBoxContainer/GameplayPanel/MarginContainer/VBoxContainer/HBoxContainer/DifficultyOption
@onready var fullscreen_check = $MarginContainer/HBoxContainer/GraphicsPanel/MarginContainer/VBoxContainer/HBoxContainer/FullScreenCheck
@onready var resolution_option: OptionButton = $MarginContainer/HBoxContainer/GraphicsPanel/MarginContainer/VBoxContainer/HBoxContainer2/Resolution_option
@onready var langauge_option: OptionButton = $MarginContainer/HBoxContainer/GameplayPanel/MarginContainer/VBoxContainer/HBoxContainer2/LangaugeOption


func _ready():
	
	 # --- Popola OptionMenu ---
	difficult_option.add_item("Facile")
	difficult_option.add_item("Medio")
	difficult_option.add_item("Difficile")
	difficult_option.select(SettingsManager.difficulty)
	
	langauge_option.add_item("Ingelse")
	langauge_option.add_item("Italiano")
	langauge_option.select(SettingsManager.language)

	resolution_option.add_item("1920x1080")
	resolution_option.add_item("1280x720")
	resolution_option.add_item("400x240")
	resolution_option.add_item("320x180")
	resolution_option.select(SettingsManager.resolution)
	
	fullscreen_check.button_pressed = SettingsManager.fullscreen
	
	master_slider.value = SettingsManager.master_volume
	music_slider.value = SettingsManager.music_volume
	sound_slider.value = SettingsManager.sfx_volume
	environment_slider.value = SettingsManager.environment_volume
	
	panels = [%GameplayPanel, %GraphicsPanel, %AudioPanel, %ControlsPanel]
	setup_panel_btn()
	show_panel(panels[0])
	gameplay_btn.grab_focus()

func setup_panel_btn() -> void:
	gameplay_btn.pressed.connect(show_panel.bind(panels[0]))
	graphics_btn.pressed.connect(show_panel.bind(panels[1]))
	audio_btn.pressed.connect(show_panel.bind(panels[2]))
	controls_btn.pressed.connect(show_panel.bind(panels[3]))

func show_panel(panel_to_show: PanelContainer) -> void:
	for panel in panels:
		panel.hide()
	
	panel_to_show.show()


# --- Connect methods --- #

# -- Gameplay -- #
func _on_difficulty_option_item_selected(index: int) -> void:
	SettingsManager.difficulty = index
	SettingsManager.save_settings()

func _on_langauge_option_item_selected(index: int) -> void:
	SettingsManager.language = index
	SettingsManager.save_settings()

# -- Graphics -- #
func _on_full_screen_check_toggled(toggled_on: bool) -> void:
	SettingsManager.fullscreen = toggled_on
	DisplayManager.apply_fullscreen(toggled_on)
	SettingsManager.save_settings()

func _on_resolution_option_item_selected(index: int) -> void:
	SettingsManager.resolution = index
	DisplayManager.apply_resolution(index)
	SettingsManager.save_settings()

# -- Sound -- #
func _on_master_slider_value_changed(value: float) -> void:
	SettingsManager.master_volume = value
	SoundManager.set_master_volume(value / 100.0)
	SettingsManager.save_settings()

func _on_music_slider_value_changed(value: float) -> void:
	SettingsManager.music_volume = value
	SoundManager.set_music_volume(value / 100.0)
	SettingsManager.save_settings()

func _on_sound_slider_value_changed(value: float) -> void:
	SettingsManager.sfx_volume = value
	SoundManager.set_sfx_volume(value / 100.0)
	SettingsManager.save_settings()

func _on_environment_slider_value_changed(value: float) -> void:
	SettingsManager.environment_volume = value
	SoundManager.set_environment_volume(value / 100.0)
	SettingsManager.save_settings()

func _on_back_pressed() -> void:
	SoundManager.play_sfx("res://Assets/Audio/DefaultBtnClick.wav")
	get_tree().change_scene_to_file("res://Scenes/UI/MainMenu.tscn")
