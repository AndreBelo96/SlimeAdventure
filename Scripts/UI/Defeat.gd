extends BaseMenu

func setup_languages():
	pass

func setup_buttons():
	buttons = [
		$ColorRect/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer3/Restart,
		$ColorRect/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2/BackLevelSelection,
		$ColorRect/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/BackMainMenu,
	]

func setup_selectors():
	selectors = [
		[$ColorRect/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer3/SelectorL, $ColorRect/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer3/SelectorR],
		[$ColorRect/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2/SelectorL, $ColorRect/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2/SelectorR],
		[$ColorRect/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/SelectorL, $ColorRect/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/SelectorR],
	]
	
	await get_tree().process_frame
	for group in selectors:
		for sel in group:
			base_positions[sel] = sel.position

func handle_navigation(_event):
	if Input.is_action_just_pressed("move_down") and current_selection < 2:
		SoundManager.play_sfx("res://Assets/Audio/TutorialBtnClick.wav")
		current_selection += 1
	elif Input.is_action_just_pressed("move_up") and current_selection > 0:
		SoundManager.play_sfx("res://Assets/Audio/TutorialBtnClick.wav")
		current_selection -= 1
	
	set_current_selection(current_selection)


func handle_selection(_index):
	SoundManager.play_sfx("res://Assets/Audio/TutorialBtnClick.wav")
	if (_index == 0):
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		GameManager.restart_level()
	elif (_index == 1):
		get_tree().change_scene_to_file("res://Scenes/UI/LocationSelection.tscn")
	elif (_index == 2):
		get_tree().change_scene_to_file("res://Scenes/UI/MainMenu.tscn")
