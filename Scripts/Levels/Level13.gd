extends "res://Scripts/Levels/LevelManager.gd"

func _ready():
	super._ready()
	set_current_level_number(13)
	victory_mode = VictoryMode.BOSS


func _on_boss_died():
	on_boss_defeated()
