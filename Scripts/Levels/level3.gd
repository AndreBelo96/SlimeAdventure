extends "res://Scripts/Levels/LevelManager.gd"

func _ready():
	super._ready()
	set_current_level_number(3)
	
	var intro_dialogue = [
		{
			"name": "Nonno Slime", 
			"text": "Alcune volte per completare il livello sarai costretto a spegnere alcune tile per terminarlo!", 
			"portrait": PortraitManager.get_portrait("Nonno"),
			"voice": "res://Assets/Audio/GranpaVoice.wav",
			"voice_speed":  VoiceManager.get_speed(VoiceManager.NONNO)
		},
		{
			"name": "Nonno Slime", 
			"text": "E ricorda, alcuni livelli per terminarli dovrai arrivare alla casella di uscita!", 
			"portrait": PortraitManager.get_portrait("Nonno"),
			"voice": "res://Assets/Audio/GranpaVoice.wav",
			"voice_speed":  VoiceManager.get_speed(VoiceManager.NONNO)
		}
	]
	
	dialog_interface.show_dialogue(intro_dialogue)
