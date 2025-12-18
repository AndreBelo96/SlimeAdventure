extends "res://Scripts/Levels/LevelManager.gd"

func _ready():
	is_boss_level = true
	super._ready()
	set_current_level_number(13)
	victory_mode = VictoryMode.BOSS
	
	await get_tree().process_frame
	await play_boss_intro()


func play_boss_intro() -> void:
	player.enter_cutscene()
	time_running = false
	
	switch_all_torches(false)
	await get_tree().create_timer(0.5).timeout
	
	await force_player_steps(4, Vector2i(0, -1))
	
	var intro_dialogue = [
		{
			"name": "Slime", 
			"text": "Non si vede un'ostia dio cane", 
			"portrait": PortraitManager.get_portrait("Slime_Sunglasses"),
			"voice": "res://Assets/Audio/Voice/SlimeVoice.wav",
			"voice_speed": VoiceManager.get_speed(VoiceManager.SLIME)
		}
	]
	
	dialog_interface.show_dialogue(intro_dialogue)
	await dialog_interface.dialogue_finished
	
	await get_tree().create_timer(0.7).timeout
	switch_all_torches(true)
	await get_tree().create_timer(1.0).timeout

	intro_dialogue = [
		{
			"name": "Slime", 
			"text": "Così va meglio", 
			"portrait": PortraitManager.get_portrait("Slime_Sunglasses"),
			"voice": "res://Assets/Audio/Voice/SlimeVoice.wav",
			"voice_speed": VoiceManager.get_speed(VoiceManager.SLIME)
		}
	]
	
	dialog_interface.show_dialogue(intro_dialogue)
	await dialog_interface.dialogue_finished

	await get_tree().create_timer(0.5).timeout
	
	intro_dialogue = [
		{
			"name": "Ludovico", 
			"text": "Mo te sfondo er culo!!", 
			"portrait": PortraitManager.get_portrait("Ludovico"),
			"voice": "res://Assets/Audio/Voice/LudovicoVoice.wav",
			"voice_speed": VoiceManager.get_speed(VoiceManager.LUDOVICO)
		},
		{
			"name": "Slime", 
			"text": "No il culo no dai!!", 
			"portrait": PortraitManager.get_portrait("Slime_Sunglasses"),
			"voice": "res://Assets/Audio/Voice/SlimeVoice.wav",
			"voice_speed": VoiceManager.get_speed(VoiceManager.SLIME)
		}
	]
	
	dialog_interface.show_dialogue(intro_dialogue)
	await dialog_interface.dialogue_finished
	
	time_running = true
	player.exit_cutscene()
	$YSort/DungeonBoss.activate()

func switch_all_torches(state: bool) -> void:
	for torch in get_tree().get_nodes_in_group("torches"):
		torch.set_state(state)

func force_player_steps(steps: int, dir: Vector2) -> void:
	for i in range(steps):
		player.force_move(dir)
		await player.move_finished

# NON viene chiamato -> qua dentro -> boss, termian livello -> aggiungi drop del pickup -> disattiva spine -> aggiungi uscita, una volta che lo chiama
func _on_boss_died():
	on_boss_defeated()
