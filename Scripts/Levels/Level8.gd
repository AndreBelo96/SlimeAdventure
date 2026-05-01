extends "res://Scripts/Levels/LevelManager.gd"

func _ready():
	ambient_preset = AudioPresets.DUNGEON_AMBIENT
	music_track = AudioPresets.DUNGEON_MUSIC
	music_autoplay = true
	
	super._ready()
	set_current_level_number(8)
	victory_mode = VictoryMode.TILES
	time_running = true
