extends Node

var music_volume: int = 50
var sfx_volume: int = 50
var fullscreen: bool = false
var difficulty: String = "Medio"
var language: String = "Italiano"

func load_settings():
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err == OK:
		music_volume = config.get_value("audio", "music_volume", 50)
		sfx_volume = config.get_value("audio", "sfx_volume", 50)
		fullscreen = config.get_value("video", "fullscreen", false)
		difficulty = config.get_value("gameplay", "difficulty", "Medio")
		language = config.get_value("gameplay", "language", "Italiano")

func save_settings():
	var config = ConfigFile.new()
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)
	config.set_value("video", "fullscreen", fullscreen)
	config.set_value("gameplay", "difficulty", difficulty)
	config.set_value("gameplay", "language", language)
	config.save("user://settings.cfg")
