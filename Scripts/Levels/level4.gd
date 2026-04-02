extends "res://Scripts/Levels/LevelManager.gd"

func _ready():
	super._ready()
	set_current_level_number(4)
	victory_mode = VictoryMode.TILES
	
	await get_tree().create_timer(0.2).timeout

	var intro_dialogue = [
		{
			"name": "Slime", 
			"text": tr("SLIME_LVL_4_TXT_1"),
			"portrait": PortraitManager.get_portrait("Slime"),
			"voice": "res://Assets/Audio/Voice/SlimeVoice.wav",
			"voice_speed": VoiceManager.get_speed(VoiceManager.SLIME)
		},
		
		{
			"name": "Nonno Slime", 
			"text": tr("GRANDPA_LVL_4_TXT_1"),
			"portrait": PortraitManager.get_portrait("Nonno"),
			"voice": "res://Assets/Audio/Voice/GranpaVoice.wav",
			"voice_speed":  VoiceManager.get_speed(VoiceManager.NONNO)
		},
		
		{
			"name": "Slime", 
			"text": tr("SLIME_LVL_4_TXT_2"),
			"portrait": PortraitManager.get_portrait("Slime"),
			"voice": "res://Assets/Audio/Voice/SlimeVoice.wav",
			"voice_speed": VoiceManager.get_speed(VoiceManager.SLIME)
		},
		
		{
			"name": "Nonno Slime", 
			"text": tr("GRANDPA_LVL_4_TXT_2"),
			"portrait": PortraitManager.get_portrait("Nonno"),
			"voice": "res://Assets/Audio/Voice/GranpaVoice.wav",
			"voice_speed":  VoiceManager.get_speed(VoiceManager.NONNO)
		},
		
		{
			"name": "Slime", 
			"text": tr("SLIME_LVL_4_TXT_3"),
			"portrait": PortraitManager.get_portrait("Slime"),
			"voice": "res://Assets/Audio/Voice/SlimeVoice.wav",
			"voice_speed": VoiceManager.get_speed(VoiceManager.SLIME)
		},
		
		{
			"name": "Nonno Slime", 
			"text": tr("GRANDPA_LVL_4_TXT_3"),
			"portrait": PortraitManager.get_portrait("Nonno"),
			"voice": "res://Assets/Audio/Voice/GranpaVoice.wav",
			"voice_speed":  VoiceManager.get_speed(VoiceManager.NONNO)
		},
		
		{
			"name": "Slime", 
			"text": tr("SLIME_LVL_4_TXT_4"),
			"portrait": PortraitManager.get_portrait("Slime"),
			"voice": "res://Assets/Audio/Voice/SlimeVoice.wav",
			"voice_speed": VoiceManager.get_speed(VoiceManager.SLIME)
		},
		
		{
			"name": "Nonno Slime", 
			"text": tr("GRANDPA_LVL_4_TXT_4"),
			"portrait": PortraitManager.get_portrait("Nonno"),
			"voice": "res://Assets/Audio/Voice/GranpaVoice.wav",
			"voice_speed":  VoiceManager.get_speed(VoiceManager.NONNO)
		},
		
		{
			"name": "Slime", 
			"text": tr("SLIME_LVL_4_TXT_5"),
			"portrait": PortraitManager.get_portrait("Slime_Sunglasses"),
			"voice": "res://Assets/Audio/Voice/SlimeVoice.wav",
			"voice_speed": VoiceManager.get_speed(VoiceManager.SLIME)
		},
		
	]

	dialog_interface.show_dialogue(intro_dialogue)
	await dialog_interface.dialogue_finished
	time_running = true
