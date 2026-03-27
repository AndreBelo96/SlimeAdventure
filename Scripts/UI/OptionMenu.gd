extends Control

var panels: Array[PanelContainer] = []

@onready var master_slider: HSlider = $MarginContainer/VBoxContainer/TabContainer/Audio/MarginContainer/VBoxContainer/VBoxContainer/MasterSlider
@onready var music_slider: HSlider = $MarginContainer/VBoxContainer/TabContainer/Audio/MarginContainer/VBoxContainer/VBoxContainer2/MusicSlider
@onready var sound_slider: HSlider = $MarginContainer/VBoxContainer/TabContainer/Audio/MarginContainer/VBoxContainer/VBoxContainer3/SoundSlider
@onready var difficult_option: OptionButton = $MarginContainer/VBoxContainer/TabContainer/Generale/MarginContainer/VBoxContainer/HBoxContainer/DifficultyOption
@onready var fullscreen_option: OptionButton = $MarginContainer/VBoxContainer/TabContainer/Video/MarginContainer/VBoxContainer/HBoxContainer/Fullscreen_option
@onready var resolution_option: OptionButton = $MarginContainer/VBoxContainer/TabContainer/Video/MarginContainer/VBoxContainer/HBoxContainer2/Resolution_option
@onready var langauge_option: OptionButton = $MarginContainer/VBoxContainer/TabContainer/Generale/MarginContainer/VBoxContainer/HBoxContainer2/LangaugeOption


func _ready():	
	populate_option_menu()
	setup_language()
	panels = [%Generale, %Audio, %Video]
	show_panel(panels[0])

func populate_option_menu() -> void:
	difficult_option.add_item(tr("DIFFICULT_1"))
	difficult_option.add_item(tr("DIFFICULT_2"))
	difficult_option.add_item(tr("DIFFICULT_3"))
	difficult_option.select(SettingsManager.difficulty)
	
	langauge_option.add_item(tr("LANGUAGE_1"))
	langauge_option.add_item("LANGUAGE_2")
	langauge_option.select(SettingsManager.language)

	resolution_option.add_item("2560x1440")
	resolution_option.add_item("1920x1080")
	resolution_option.add_item("1280x720")
	resolution_option.add_item("640x360")
	resolution_option.select(SettingsManager.resolution)
	
	fullscreen_option.add_item(tr("FULLSCREEN_CHK"))
	fullscreen_option.add_item("Schermo Intero Senza Bordi")
	fullscreen_option.add_item("Finestra")
	
	master_slider.value = SettingsManager.master_volume
	music_slider.value = SettingsManager.music_volume
	sound_slider.value = SettingsManager.sfx_volume

func setup_language() -> void:
	%GameplayBtn.text = tr("GAMEPLAY_BTN")
	$MarginContainer/HBoxContainer/GameplayPanel/MarginContainer/VBoxContainer/HBoxContainer/Label.text = tr("DIFFICULT_LABEL")
	$MarginContainer/HBoxContainer/GameplayPanel/MarginContainer/VBoxContainer/HBoxContainer2/Label.text = tr("LANGUAGE_LABEL")
	
	%GraphicsBtn.text = tr("GRAPHICS_BTN")
	$MarginContainer/HBoxContainer/GraphicsPanel/MarginContainer/VBoxContainer/HBoxContainer/Label.text = tr("FULLSCREEN_CHK")
	$MarginContainer/HBoxContainer/GraphicsPanel/MarginContainer/VBoxContainer/HBoxContainer2/Label.text = tr("RESOLUTION_LABEL")
	
	%AudioBtn.text = tr("AUDIO_BTN")
	$MarginContainer/HBoxContainer/AudioPanel/MarginContainer/VBoxContainer/VBoxContainer/Label.text = tr("VOLUME_1")
	$MarginContainer/HBoxContainer/AudioPanel/MarginContainer/VBoxContainer/VBoxContainer2/Label.text = tr("VOLUME_2")
	$MarginContainer/HBoxContainer/AudioPanel/MarginContainer/VBoxContainer/VBoxContainer3/Label.text = tr("VOLUME_3")
	$MarginContainer/HBoxContainer/AudioPanel/MarginContainer/VBoxContainer/VBoxContainer4/Label.text = tr("VOLUME_4")
	
	%ControlsBtn.text = tr("CONTROLS_BTN")
	
	$MarginContainer/HBoxContainer/VBoxContainer/Back.text = tr("BACK_BTN")
	
	pass

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
	var lang = SettingsManager.get_locale_from_index(index)
	TranslationServer.set_locale(lang)
	setup_language()
	SettingsManager.save_settings()

# -- Graphics -- #
func _on_fullscreen_option_item_selected(index: int) -> void:
	SettingsManager.fullscreen = index
	DisplayManager.apply_fullscreen(index)
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
