extends "res://Scripts/Levels/LevelManager.gd"

func _ready():
	super._ready()
	set_current_level_number(10)
	victory_mode = VictoryMode.TILES
	time_running = true
