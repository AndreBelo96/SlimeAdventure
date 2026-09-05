extends "res://Scripts/Levels/LevelManager.gd"

func _ready():
	ambient_preset = AudioPresets.DUNGEON_AMBIENT
	music_track = AudioPresets.DUNGEON_MUSIC
	music_autoplay = false

	super._ready()
	set_current_level_number(5)
	victory_mode = VictoryMode.TILES

	await play_intro([
		dlg("Slime", "SLIME_LVL_5_TXT_1", "Slime_Sunglasses", "res://Assets/Audio/Sound/Voice/SlimeVoice.wav", VoiceManager.SLIME)
	], 0.2)
	
	time_running = true
	SoundManager.play_music(music_track)
