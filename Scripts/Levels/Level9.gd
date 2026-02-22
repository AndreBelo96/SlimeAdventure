extends "res://Scripts/Levels/LevelManager.gd"

func _ready():
	super._ready()
	set_current_level_number(9)
	victory_mode = VictoryMode.TILES
	
	var intro_dialogue = [
		{
			"name": "Slime", 
			"text": "Chissà se nonno si riferiva a questo quando parlava delle torce e la muffa...", 
			"portrait": PortraitManager.get_portrait("Slime_Sunglasses"),
			"voice": "res://Assets/Audio/Voice/SlimeVoice.wav",
			"voice_speed": VoiceManager.get_speed(VoiceManager.SLIME)
		}
	]
	
	dialog_interface.show_dialogue(intro_dialogue)
	await dialog_interface.dialogue_finished
	time_running = true
