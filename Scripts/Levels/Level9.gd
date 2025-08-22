extends "res://Scripts/Levels/LevelManager.gd"

var slime_face = preload("res://Assets/Sprites/Player/Sunglasses.png")

func _ready():
	super._ready()
	set_current_level_number(9)
	var intro_dialogue = [
		{"name": "Slime", "text": "Cosa è questo buio?", "portrait": slime_face}
	]

	dialog_interface.show_dialogue(intro_dialogue)
