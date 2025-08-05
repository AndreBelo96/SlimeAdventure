extends "res://Scripts/Levels/levelBase.gd"

var slime_face = preload("res://Assets/Sprites/Player/Sunglasses.png")

func _ready():
	super._ready()
	set_background("res://Scenes/Backgrounds/BackgroundDungeon.tscn")
	set_current_level_number(5)
	await get_tree().create_timer(0.2).timeout
	
	var intro_dialogue = [
		{"name": "Slime", "text": "Qualcosa non va, cosa sono queste trappole?", "portrait": slime_face}
	]

	dialog_interface.show_dialogue(intro_dialogue)
