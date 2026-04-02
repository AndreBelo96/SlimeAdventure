extends Control

@onready var master_slider: HSlider = $MarginContainer/VBoxContainer/TabContainer/Audio/MarginContainer/VBoxContainer/VBoxContainer/MasterSlider
@onready var music_slider: HSlider = $MarginContainer/VBoxContainer/TabContainer/Audio/MarginContainer/VBoxContainer/VBoxContainer2/MusicSlider
@onready var sound_slider: HSlider = $MarginContainer/VBoxContainer/TabContainer/Audio/MarginContainer/VBoxContainer/VBoxContainer3/SoundSlider
@onready var difficult_option: OptionButton = $MarginContainer/VBoxContainer/TabContainer/Generale/MarginContainer/VBoxContainer/HBoxContainer/DifficultyOption
@onready var langauge_option: OptionButton = $MarginContainer/VBoxContainer/TabContainer/Generale/MarginContainer/VBoxContainer/HBoxContainer2/LangaugeOption

@onready var back_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/Back

## --- Labels --- ## #TODO titoli
@onready var difficult_label: Label = $MarginContainer/VBoxContainer/TabContainer/Generale/MarginContainer/VBoxContainer/HBoxContainer/Label
@onready var languagge_label: Label = $MarginContainer/VBoxContainer/TabContainer/Generale/MarginContainer/VBoxContainer/HBoxContainer2/Label

@onready var master_label: Label = $MarginContainer/VBoxContainer/TabContainer/Audio/MarginContainer/VBoxContainer/VBoxContainer/Label
@onready var music_label: Label = $MarginContainer/VBoxContainer/TabContainer/Audio/MarginContainer/VBoxContainer/VBoxContainer2/Label
@onready var sound_label: Label = $MarginContainer/VBoxContainer/TabContainer/Audio/MarginContainer/VBoxContainer/VBoxContainer3/Label

func _ready():	
	populate_option_menu()
	setup_language()

func populate_option_menu() -> void:
	difficult_option.add_item(tr("DIFFICULT_1"))
	difficult_option.add_item(tr("DIFFICULT_2"))
	difficult_option.add_item(tr("DIFFICULT_3"))
	difficult_option.select(SettingsManager.difficulty)
	
	langauge_option.add_item(tr("LANGUAGE_1"))
	langauge_option.add_item("LANGUAGE_2")
	langauge_option.select(SettingsManager.language)
	
	master_slider.value = SettingsManager.master_volume
	music_slider.value = SettingsManager.music_volume
	sound_slider.value = SettingsManager.sfx_volume

func setup_language() -> void:
	difficult_label.text = tr("DIFFICULT_LABEL")
	languagge_label.text = tr("LANGUAGE_LABEL")
	
	master_label.text = tr("VOLUME_1")
	music_label.text = tr("VOLUME_2")
	sound_label.text = tr("VOLUME_3")
	
	back_button.text = tr("BACK_BTN")

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

# -- Back -- #
func _on_back_pressed() -> void:
	SoundManager.play_sfx("res://Assets/Audio/TutorialBtnClick.wav")
	get_tree().change_scene_to_file("res://Scenes/UI/MainMenu.tscn")
