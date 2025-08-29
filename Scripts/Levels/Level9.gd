extends "res://Scripts/Levels/LevelManager.gd"

func _ready():
	super._ready()
	set_current_level_number(9)
	var intro_dialogue = [
		{
			"name": "Slime", 
			"text": "Chissà se nonno si riferiva a questo quando parlava delle torce e la muffa...", 
			"portrait": PortraitManager.get_portrait("Slime_Sunglasses"),
			"voice": "res://Assets/Audio/SlimeVoice.wav",
			"voice_speed": VoiceManager.get_speed(VoiceManager.SLIME)
		}
	]
	await get_tree().process_frame
	await get_tree().process_frame
	dialog_interface.show_dialogue(intro_dialogue)
