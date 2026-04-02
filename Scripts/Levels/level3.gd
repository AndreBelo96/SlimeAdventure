extends "res://Scripts/Levels/LevelManager.gd"

func _ready():
	super._ready()
	set_current_level_number(3)
	victory_mode = VictoryMode.TILES
	
	var intro_dialogue = [
		{
			"name": "Nonno Slime", 
			"text": tr("GRANDPA_LVL_3_TXT_1"),
			"portrait": PortraitManager.get_portrait("Nonno"),
			"voice": "res://Assets/Audio/Voice/GranpaVoice.wav",
			"voice_speed":  VoiceManager.get_speed(VoiceManager.NONNO)
		}
	]
	
	dialog_interface.show_dialogue(intro_dialogue)
	await dialog_interface.dialogue_finished
	time_running = true
