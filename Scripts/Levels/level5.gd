extends "res://Scripts/Levels/LevelManager.gd"

func _ready():
	super._ready()
	set_current_level_number(5)
	await get_tree().create_timer(0.2).timeout
	
	var intro_dialogue = [
		{
			"name": "Slime", 
			"text": "Cosa aveva detto nonno sulle trappole? Qualcosa sul non toccarle mi pare...", 
			"portrait": PortraitManager.get_portrait("Slime_Sunglasses"),
			"voice": "res://Assets/Audio/Voice/SlimeVoice.wav",
			"voice_speed": VoiceManager.get_speed(VoiceManager.SLIME)
		}
	]
	
	dialog_interface.show_dialogue(intro_dialogue)
