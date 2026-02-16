extends BaseMenu

func _ready():
	setup_languages()
	setup_buttons()
	setup_selectors()
	setup_mouse()
	set_current_selection(0)

func setup_languages():
	pass

func setup_buttons():
	buttons_main = [
		$ColorRect/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer3/Restart,
		$ColorRect/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2/BackLevelSelection,
		$ColorRect/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/BackMainMenu,
	]

func setup_selectors():
	selectors_main = [
		[$ColorRect/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer3/SelectorL, $ColorRect/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer3/SelectorR],
		[$ColorRect/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2/SelectorL, $ColorRect/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2/SelectorR],
		[$ColorRect/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/SelectorL, $ColorRect/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/SelectorR],
	]
	
	await get_tree().process_frame
	for group in selectors_main:
		for sel in group:
			base_positions[sel] = sel.position

func handle_navigation(_event):
	if Input.is_action_just_pressed("move_down") and current_selection < 2:
		SoundManager.play_sfx(SFX_MOVE)
		current_selection += 1
	elif Input.is_action_just_pressed("move_up") and current_selection > 0:
		SoundManager.play_sfx(SFX_MOVE)
		current_selection -= 1
	
	set_current_selection(current_selection)

func handle_selection(_index):
	SoundManager.play_sfx(SFX_CONFIRM)
	if (_index == 0):
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		GameManager.restart_level()
	elif (_index == 1):
		GameManager.return_to_location_menu()
	elif (_index == 2):
		GameManager.return_to_menu()
