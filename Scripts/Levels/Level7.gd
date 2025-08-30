extends "res://Scripts/Levels/LevelManager.gd"

func _ready():
	super._ready()
	set_current_level_number(7)
	var intro_dialogue = [
		{
			"name": "Slime", 
			"text": "Ah si ora ricordo: ", 
			"portrait": PortraitManager.get_portrait("Slime_Sunglasses"),
			"voice": "res://Assets/Audio/Voice/SlimeVoice.wav",
			"voice_speed": VoiceManager.get_speed(VoiceManager.SLIME)
		},
		{
			"name": "Slime", 
			"text": "\"Le spine possono ucciderti, soprattutto quelle a passi, stai attento! AH.. AH.. AH..\"", 
			"portrait": PortraitManager.get_portrait("Slime_Sunglasses"),
			"voice": "res://Assets/Audio/Voice/GranpaVoice.wav",
			"voice_speed":  VoiceManager.get_speed(VoiceManager.NONNO)
		},
		{
			"name": "Slime", 
			"text": "Già mi manca, non vedo l'ora di tornare per raccontargli tutto!", 
			"portrait": PortraitManager.get_portrait("Slime_Sunglasses"),
			"voice": "res://Assets/Audio/Voice/SlimeVoice.wav",
			"voice_speed": VoiceManager.get_speed(VoiceManager.SLIME)
		},
	]
	
	dialog_interface.show_dialogue(intro_dialogue)
