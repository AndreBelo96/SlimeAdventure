extends "res://Scripts/Levels/LevelManager.gd"

func _ready():
	super._ready()
	set_current_level_number(2)
	victory_mode = VictoryMode.TILES
	
	await play_intro([
		dlg("Nonno Slime", "GRANDPA_LVL_2_TXT_1", "Nonno", "res://Assets/Audio/Sound/Voice/GranpaVoice.wav", VoiceManager.NONNO)
	])
	
	time_running = true
