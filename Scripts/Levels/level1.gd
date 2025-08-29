extends "res://Scripts/Levels/LevelManager.gd"

func _ready():
	super._ready()
	set_current_level_number(1)
	
	var intro_dialogue = [
		{
			"name": "Nonno Slime", 
			"text": "Usa le frecce direzionali per muoverti. Cerca di attivare tutte le tile per avanzare!!", 
			"portrait": PortraitManager.get_portrait("Nonno"),
			"voice": "res://Assets/Audio/GranpaVoice.wav",
			"voice_speed":  VoiceManager.get_speed(VoiceManager.NONNO)
		}
	]
	
	dialog_interface.show_dialogue(intro_dialogue)
