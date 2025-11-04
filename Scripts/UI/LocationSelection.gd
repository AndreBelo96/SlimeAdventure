extends BaseMenu

func setup_languages():
	#$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer/HBoxContainer/Button/Start.text = tr("START_BTN")
	pass

func setup_buttons():
	buttons = [
		$MarginContainer/VBoxContainer/CenterContainer2/LocationContainer/VBoxContainer/Tutorial,
		$MarginContainer/VBoxContainer/CenterContainer2/LocationContainer/VBoxContainer2/Dungeon,
		$MarginContainer/VBoxContainer/CenterContainer2/LocationContainer/VBoxContainer3/Forest,
		$MarginContainer/VBoxContainer/CenterContainer3/HBoxContainer/Button
	]

func setup_selectors():
	selectors = [
		[$MarginContainer/VBoxContainer/CenterContainer2/LocationContainer/VBoxContainer/Control/Selector],
		[$MarginContainer/VBoxContainer/CenterContainer2/LocationContainer/VBoxContainer2/Control/Selector],
		[$MarginContainer/VBoxContainer/CenterContainer2/LocationContainer/VBoxContainer3/Control/Selector],
		[$MarginContainer/VBoxContainer/CenterContainer3/HBoxContainer/SelectorL, $MarginContainer/VBoxContainer/CenterContainer3/HBoxContainer/SelectorR]
	]
	
	await get_tree().process_frame
	for group in selectors:
		for sel in group:
			base_positions[sel] = sel.position

func handle_navigation(_event):
	if Input.is_action_just_pressed("move_right") and current_selection < 3:
		SoundManager.play_sfx("res://Assets/Audio/TutorialBtnClick.wav")
		current_selection += 1
	elif Input.is_action_just_pressed("move_left") and current_selection > 0:
		SoundManager.play_sfx("res://Assets/Audio/TutorialBtnClick.wav")
		current_selection -= 1
	elif Input.is_action_just_pressed("move_down") and current_selection < 3:
		SoundManager.play_sfx("res://Assets/Audio/TutorialBtnClick.wav")
		current_selection = 3
	elif Input.is_action_just_pressed("move_up") and current_selection > 0:
		SoundManager.play_sfx("res://Assets/Audio/TutorialBtnClick.wav")
		current_selection = 0
	
	set_current_selection(current_selection)

func handle_selection(_index):
	if (_index == 3):
		SoundManager.play_sfx("res://Assets/Audio/TutorialBtnClick.wav")
		get_tree().change_scene_to_file("res://Scenes/UI/MainMenu.tscn")
		return
	
	var location_name = GameManager.Location.keys()[_index]
	
	if GameManager.is_location_locked(location_name):
		#SoundManager.play_sfx("res://Assets/Audio/LockedBtn.wav") # TODO un suono diverso e setup tasto bloccato, disegni sopra lucchetto?
		print("Location bloccata:", location_name)
		return
	
	# Se è sbloccata, procedi
	GameManager.location_selected = GameManager.Location.values()[_index]
	SoundManager.play_sfx("res://Assets/Audio/TutorialBtnClick.wav")
	
	if (_index == 0):
		get_tree().change_scene_to_file("res://Scenes/UI/LevelMenu.tscn")
	elif (_index == 1):
		get_tree().change_scene_to_file("res://Scenes/UI/LevelMenu.tscn")
	elif (_index == 2):
		get_tree().change_scene_to_file("res://Scenes/UI/LevelMenu.tscn")
