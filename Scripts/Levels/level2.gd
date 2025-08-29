extends "res://Scripts/Levels/LevelManager.gd"

func _ready():
	super._ready()
	set_current_level_number(2)
	
	var intro_dialogue = [
		{
			"name": "Nonno Slime", 
			"text": "Perfetto, bravissimo! Ora prova a terminare questo da solo!", 
			"portrait": PortraitManager.get_portrait("Nonno"),
			"voice": "res://Assets/Audio/GranpaVoice.wav",
			"voice_speed":  VoiceManager.get_speed(VoiceManager.NONNO)
		}
	]
	
	await get_tree().process_frame
	await get_tree().process_frame
	dialog_interface.show_dialogue(intro_dialogue)
