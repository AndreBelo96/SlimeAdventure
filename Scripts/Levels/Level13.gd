extends "res://Scripts/Levels/LevelManager.gd"

func _ready():
	is_boss_level = true
	super._ready()
	set_current_level_number(13)
	victory_mode = VictoryMode.BOSS
	
	## fai fare il movimento di due senza muovere il boss(?)
	
	var intro_dialogue = [
		{
			"name": "Ludovico", 
			"text": "Mo te sfondo er culo!!", 
			"portrait": PortraitManager.get_portrait("Ludovico"),
			"voice": "res://Assets/Audio/Voice/Ludovico.wav",
			"voice_speed":  VoiceManager.get_speed(VoiceManager.LUDOVICO)
		}
	]
	
	dialog_interface.show_dialogue(intro_dialogue)


func _on_boss_died():
	on_boss_defeated()
