extends BaseMenu

func setup_languages():
	$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer/HBoxContainer/Button/Start.text = tr("START_BTN")
	$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer2/HBoxContainer/Button/Profile.text = "Profile"
	$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer3/HBoxContainer/Button/Scoreboard.text = "Scoreboard"
	$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer4/HBoxContainer/Button/Option.text = tr("OPTIONS_BTN")
	$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer5/HBoxContainer/Button/Exit.text = tr("EXIT_BTN")

func setup_buttons():
	buttons = [
		$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer/HBoxContainer/Button,
		$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer2/HBoxContainer/Button,
		$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer3/HBoxContainer/Button,
		$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer4/HBoxContainer/Button,
		$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer5/HBoxContainer/Button
	]

func setup_selectors():
	selectors = [
		[$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer/HBoxContainer/SelectorL, $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer/HBoxContainer/SelectorR],
		[$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer2/HBoxContainer/SelectorL, $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer2/HBoxContainer/SelectorR],
		[$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer3/HBoxContainer/SelectorL, $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer3/HBoxContainer/SelectorR],
		[$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer4/HBoxContainer/SelectorL, $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer4/HBoxContainer/SelectorR],
		[$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer5/HBoxContainer/SelectorL, $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer5/HBoxContainer/SelectorR],
	]
	
	await get_tree().process_frame
	for group in selectors:
		for sel in group:
			base_positions[sel] = sel.position

func handle_navigation(_event):
	if Input.is_action_just_pressed("move_down") and current_selection < 4:
		SoundManager.play_sfx("res://Assets/Audio/TutorialBtnClick.wav")
		current_selection += 1
	elif Input.is_action_just_pressed("move_up") and current_selection > 0:
		SoundManager.play_sfx("res://Assets/Audio/TutorialBtnClick.wav")
		current_selection -= 1
	
	set_current_selection(current_selection)


func handle_selection(_index):
	SoundManager.play_sfx("res://Assets/Audio/TutorialBtnClick.wav")
	if (_index == 0):
		get_tree().change_scene_to_file("res://Scenes/UI/LocationSelection.tscn")
	elif (_index == 1):
		pass
	elif (_index == 2):
		pass
	elif (_index == 3):
		get_tree().change_scene_to_file("res://Scenes/UI/OptionMenu.tscn")
	elif (_index == 4):
		get_tree().quit()
