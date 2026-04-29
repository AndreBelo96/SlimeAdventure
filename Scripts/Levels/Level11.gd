extends "res://Scripts/Levels/LevelManager.gd"

func _ready():
	super._ready()
	ambient_controller.ambient_events = AudioPresets.DUNGEON_AMBIENT
	set_current_level_number(11)
	victory_mode = VictoryMode.TILES
	time_running = true
