extends "res://Scripts/Levels/LevelManager.gd"

func _ready():
	super._ready()
	ambient_controller.ambient_events = AudioPresets.DUNGEON_AMBIENT
	set_current_level_number(9)
	victory_mode = VictoryMode.TILES
	
	var intro_dialogue = [
		{
			"name": "Slime", 
			"text": tr("SLIME_LVL_9_TXT_1"),
			"portrait": PortraitManager.get_portrait("Slime_Sunglasses"),
			"voice": "res://Assets/Audio/Sound/Voice/SlimeVoice.wav",
			"voice_speed": VoiceManager.get_speed(VoiceManager.SLIME)
		}
	]
	
	dialog_interface.show_dialogue(intro_dialogue)
	await dialog_interface.dialogue_finished
	time_running = true
