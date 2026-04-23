extends "res://Scripts/Levels/LevelManager.gd"

@export var pickaxe_pickup_scene: PackedScene

func _ready():
	is_boss_level = true
	super._ready()
	set_current_level_number(13)
	victory_mode = VictoryMode.BOSS
	
	await get_tree().process_frame
	await play_boss_intro()

func play_boss_intro() -> void:
	player.enter_cutscene()
	
	switch_all_torches(false)
	await get_tree().create_timer(0.5).timeout
	
	await force_player_steps(4, Vector2i(0, -1))
	
	var intro_dialogue = [
		{
			"name": "Slime", 
			"text": tr("SLIME_LVL_13_TXT_1"),
			"portrait": PortraitManager.get_portrait("Slime_Sunglasses"),
			"voice": "res://Assets/Audio/Sound/Voice/SlimeVoice.wav",
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
			"text": tr("SLIME_LVL_13_TXT_2"),
			"portrait": PortraitManager.get_portrait("Slime_Sunglasses"),
			"voice": "res://Assets/Audio/Sound/Voice/SlimeVoice.wav",
			"voice_speed": VoiceManager.get_speed(VoiceManager.SLIME)
		}
	]
	
	dialog_interface.show_dialogue(intro_dialogue)
	await dialog_interface.dialogue_finished

	await get_tree().create_timer(0.5).timeout
	
	intro_dialogue = [
		{
			"name": "Ludovico", 
			"text": tr("LUDOVICO_LVL_13_TXT_1"),
			"portrait": PortraitManager.get_portrait("Ludovico"),
			"voice": "res://Assets/Audio/Sound/Voice/LudovicoVoice.wav",
			"voice_speed": VoiceManager.get_speed(VoiceManager.LUDOVICO)
		},
		{
			"name": "Slime", 
			"text": tr("SLIME_LVL_13_TXT_3"),
			"portrait": PortraitManager.get_portrait("Slime_Sunglasses"),
			"voice": "res://Assets/Audio/Sound/Voice/SlimeVoice.wav",
			"voice_speed": VoiceManager.get_speed(VoiceManager.SLIME)
		},
		{
			"name": "Ludovico", 
			"text": tr("LUDOVICO_LVL_13_TXT_2"),
			"portrait": PortraitManager.get_portrait("Ludovico"),
			"voice": "res://Assets/Audio/Sound/Voice/LudovicoVoice.wav",
			"voice_speed": VoiceManager.get_speed(VoiceManager.LUDOVICO)
		},
	]
	
	dialog_interface.show_dialogue(intro_dialogue)
	await dialog_interface.dialogue_finished
	
	time_running = true
	player.exit_cutscene()
	$YSort/DungeonBoss.activate()

func switch_all_torches(state: bool) -> void:
	for torch in get_tree().get_nodes_in_group("torches"):
		torch.set_state(state)

func force_player_steps(steps_to_do: int, dir: Vector2) -> void:
	for i in range(steps_to_do):
		player.force_move(dir)
		await player.move_finished

func _on_boss_died():
	on_boss_defeated()

# ---- Boss defeated ---- #
func _on_boss_defeated_custom():
	disable_all_spikes()
	drop_pickaxe_pickup()
	
func disable_all_spikes():
	if level_logic.has_method("disable_all_spikes"):
		level_logic.disable_all_spikes()

func drop_pickaxe_pickup():
	if not pickaxe_pickup_scene:
		return
	
	var bosses := get_tree().get_nodes_in_group("enemy")
	if bosses.is_empty():
		return
	
	var boss: Node2D = bosses[0]
	
	var pickup := pickaxe_pickup_scene.instantiate() as PickupBase
	pickup_layer.add_child(pickup)
	pickup.snap_to_tile_center(pickup_layer.map_to_local(boss.posizione_tile), boss.posizione_tile)
	pickup.is_active = true
