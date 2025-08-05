extends "res://Scripts/Levels/levelBase.gd"

var slime_face = preload("res://Assets/Sprites/Player/Sunglasses.png")

func _ready():
	super._ready()
	set_background("res://Scenes/Backgrounds/BackgroundDungeon.tscn")
	set_current_level_number(7)
	var intro_dialogue = [
		{"name": "Slime", "text": "Ogni passo è importante", "portrait": slime_face}
	]

	dialog_interface.show_dialogue(intro_dialogue)
