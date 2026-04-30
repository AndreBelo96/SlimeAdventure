extends "res://Scripts/Levels/LevelManager.gd"

func _ready():
	ambient_preset = AudioPresets.DUNGEON_AMBIENT
	
	super._ready()
	set_current_level_number(12)
	victory_mode = VictoryMode.TILES
	time_running = true
