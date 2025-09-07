extends Control

@onready var music_slider = $CanvasLayer/VBoxContainer/VolumeMusica/music_slider
@onready var sfx_slider = $CanvasLayer/VBoxContainer/VolumeEffetti/sfx_slider
@onready var difficult_option = $CanvasLayer/VBoxContainer/Difficolta/difficult_option
@onready var fullscreen_check = $"CanvasLayer/VBoxContainer/Schermo intero/fullscreen_check"
@onready var language_option = $CanvasLayer/VBoxContainer/Lingua/language_option

func _ready():
	# Carica le impostazioni salvate (se presenti)
	music_slider.value = ProjectSettings.get_setting("audio/music_volume", 50)
	sfx_slider.value = ProjectSettings.get_setting("audio/sfx_volume", 50)
	fullscreen_check.button_pressed = ProjectSettings.get_setting("display/window/size/fullscreen", false)

	difficult_option.add_item("Facile")
	difficult_option.add_item("Medio")
	difficult_option.add_item("Difficile")

	language_option.add_item("Ingelse")
	language_option.add_item("Italiano")

func _on_music_slider_value_changed(value):
	SettingsManager.music_volume = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value / 100.0))
	SettingsManager.save_settings()

func _on_sfx_slider_value_changed(value):
	SettingsManager.sfx_volume = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value / 100.0))
	SettingsManager.save_settings()

func _on_difficult_option_item_selected(index: int) -> void:
	pass # Replace with function body.
	SettingsManager.save_settings()

func _on_fullscreen_check_toggled(pressed):
	SettingsManager.fullscreen = pressed
	ProjectSettings.set_setting("display/window/size/fullscreen", pressed)
	SettingsManager.save_settings()

func _on_language_option_item_selected(index: int) -> void:
	pass # Replace with function body.
	SettingsManager.save_settings()
