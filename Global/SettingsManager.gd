extends Node

var master_volume: float = 50
var music_volume: float = 50
var sfx_volume: float = 50
var environment_volume: float = 50

var fullscreen: bool = false
var resolution: int = 0

var difficulty: int = 0
var language: int = 0

func load_settings():
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err == OK:
		master_volume = config.get_value("audio", "master_volume", 50)
		music_volume = config.get_value("audio", "music_volume", 50)
		sfx_volume = config.get_value("audio", "sfx_volume", 50)
		environment_volume = config.get_value("audio", "environment_volume", 50)
		fullscreen = config.get_value("video", "fullscreen", false)
		resolution = config.get_value("video", "resolution", 0)
		difficulty = config.get_value("gameplay", "difficulty", 0)
		language = config.get_value("gameplay", "language", 0)

func save_settings():
	var config = ConfigFile.new()
	config.set_value("audio", "master_volume", master_volume)
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)
	config.set_value("audio", "environment_volume", environment_volume)
	config.set_value("video", "fullscreen", fullscreen)
	config.set_value("video", "resolution", resolution)
	config.set_value("gameplay", "difficulty", difficulty)
	config.set_value("gameplay", "language", language)
	config.save("user://settings.cfg")
	
