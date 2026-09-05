extends "res://Scripts/Levels/LevelManager.gd"

func _ready():
	ambient_preset = AudioPresets.DUNGEON_AMBIENT
	music_track = AudioPresets.DUNGEON_MUSIC
	music_autoplay = false

	super._ready()
	set_current_level_number(4)
	victory_mode = VictoryMode.TILES
	
	await play_intro([
		dlg("Slime", "SLIME_LVL_4_TXT_1", "Slime", "res://Assets/Audio/Sound/Voice/SlimeVoice.wav", VoiceManager.SLIME),
		dlg("Nonno Slime", "GRANDPA_LVL_4_TXT_1", "Nonno", "res://Assets/Audio/Sound/Voice/GranpaVoice.wav", VoiceManager.NONNO),
		dlg("Slime", "SLIME_LVL_4_TXT_2", "Slime", "res://Assets/Audio/Sound/Voice/SlimeVoice.wav", VoiceManager.SLIME),
		dlg("Nonno Slime", "GRANDPA_LVL_4_TXT_2", "Nonno", "res://Assets/Audio/Sound/Voice/GranpaVoice.wav", VoiceManager.NONNO),
		dlg("Slime", "SLIME_LVL_4_TXT_3", "Slime", "res://Assets/Audio/Sound/Voice/SlimeVoice.wav", VoiceManager.SLIME),
		dlg("Nonno Slime", "GRANDPA_LVL_4_TXT_3", "Nonno", "res://Assets/Audio/Sound/Voice/GranpaVoice.wav", VoiceManager.NONNO),
		dlg("Slime", "SLIME_LVL_4_TXT_4", "Slime", "res://Assets/Audio/Sound/Voice/SlimeVoice.wav", VoiceManager.SLIME),
		dlg("Nonno Slime", "GRANDPA_LVL_4_TXT_4", "Nonno", "res://Assets/Audio/Sound/Voice/GranpaVoice.wav", VoiceManager.NONNO),
		dlg("Slime", "SLIME_LVL_4_TXT_5", "Slime_Sunglasses", "res://Assets/Audio/Sound/Voice/SlimeVoice.wav", VoiceManager.SLIME),
	], 0.2)
	
	time_running = true
	SoundManager.play_music(music_track)
