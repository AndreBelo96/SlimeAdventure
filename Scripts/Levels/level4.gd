extends "res://Scripts/Levels/LevelManager.gd"

var slime_face = preload("res://Assets/Sprites/Player/Sunglasses.png")

func _ready():
	super._ready()
	set_current_level_number(4)
	#spanw_ogg_decorativo(OggettiDecorativi.PORTA_CELLA, Vector2i(3, -3), Vector2(16, -12))
	await get_tree().create_timer(0.2).timeout

	var intro_dialogue = [
		{"name": "Slime", "text": "Dove mi trovo?", "portrait": slime_face},
		{"name": "Slime", "text": "Devo trovare un modo di uscire da qui.", "portrait": slime_face}
	]

	dialog_interface.show_dialogue(intro_dialogue)
