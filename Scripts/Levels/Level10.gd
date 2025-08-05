extends "res://Scripts/Levels/levelBase.gd"

func _ready():
	super._ready()
	set_background("res://Scenes/Backgrounds/BackgroundDungeon.tscn")
	set_current_level_number(10)
