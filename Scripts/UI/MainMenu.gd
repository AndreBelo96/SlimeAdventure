extends BaseMenu

func setup_languages():
	$MenuContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer/HBoxContainer/Button/Start.text = tr("START_BTN")
	$MenuContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer2/HBoxContainer/Button/Profile.text = "Profile"
	$MenuContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer3/HBoxContainer/Button/Scoreboard.text = "Scoreboard"
	$MenuContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer4/HBoxContainer/Button/Option.text = tr("OPTIONS_BTN")
	$MenuContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer5/HBoxContainer/Button/Exit.text = tr("EXIT_BTN")

## ----- Buttons setup ----- ##
func setup_main_buttons():
	buttons_main = [
		$MenuContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer/HBoxContainer/Button,
		$MenuContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer2/HBoxContainer/Button,
		$MenuContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer3/HBoxContainer/Button,
		$MenuContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer4/HBoxContainer/Button,
		$MenuContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer5/HBoxContainer/Button
	]

func setup_location_buttons():
	buttons_location = [
		$LocationContainer/VBoxContainer/CenterContainer2/LocationContainer/VBoxContainer/Tutorial,
		$LocationContainer/VBoxContainer/CenterContainer2/LocationContainer/VBoxContainer2/Dungeon,
		$LocationContainer/VBoxContainer/CenterContainer2/LocationContainer/VBoxContainer3/Forest,
		$LocationContainer/VBoxContainer/CenterContainer3/HBoxContainer/Button
	]

## ----- Selectors setup ----- ##
func setup_main_selectors():
	selectors_main  = [
		[$MenuContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer/HBoxContainer/SelectorL, $MenuContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer/HBoxContainer/SelectorR],
		[$MenuContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer2/HBoxContainer/SelectorL, $MenuContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer2/HBoxContainer/SelectorR],
		[$MenuContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer3/HBoxContainer/SelectorL, $MenuContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer3/HBoxContainer/SelectorR],
		[$MenuContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer4/HBoxContainer/SelectorL, $MenuContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer4/HBoxContainer/SelectorR],
		[$MenuContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer5/HBoxContainer/SelectorL, $MenuContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer5/HBoxContainer/SelectorR],
	]
	
	await get_tree().process_frame
	for group in selectors_main:
		for sel in group:
			base_positions[sel] = sel.position

func setup_location_selectors():
	selectors_location = [
		[$LocationContainer/VBoxContainer/CenterContainer2/LocationContainer/VBoxContainer/Control/Selector],
		[$LocationContainer/VBoxContainer/CenterContainer2/LocationContainer/VBoxContainer2/Control/Selector],
		[$LocationContainer/VBoxContainer/CenterContainer2/LocationContainer/VBoxContainer3/Control/Selector],
		[$LocationContainer/VBoxContainer/CenterContainer3/HBoxContainer/SelectorL, $LocationContainer/VBoxContainer/CenterContainer3/HBoxContainer/SelectorR]
	]
	
	await get_tree().process_frame
	for group in selectors_location:
		for sel in group:
			base_positions[sel] = sel.position

func handle_navigation(_event):
	if current_state == MenuState.MAIN_MENU:
		if Input.is_action_just_pressed("move_down") and current_selection < 4:
			SoundManager.play_sfx(SFX_MOVE)
			current_selection += 1
		elif Input.is_action_just_pressed("move_up") and current_selection > 0:
			SoundManager.play_sfx(SFX_MOVE)
			current_selection -= 1
	elif current_state == MenuState.LOCATION_SELECT:
		if Input.is_action_just_pressed("move_right") and current_selection < 3:
			SoundManager.play_sfx(SFX_MOVE)
			current_selection += 1
		elif Input.is_action_just_pressed("move_left") and current_selection > 0:
			SoundManager.play_sfx(SFX_MOVE)
			current_selection -= 1
		elif Input.is_action_just_pressed("move_down") and current_selection < 3:
			SoundManager.play_sfx(SFX_MOVE)
			current_selection = 3
		elif Input.is_action_just_pressed("move_up") and current_selection > 0:
			SoundManager.play_sfx(SFX_MOVE)
			current_selection = 0
	
	set_current_selection(current_selection)

func handle_selection(_index):
	
	if current_state == MenuState.MAIN_MENU:
		SoundManager.play_sfx(SFX_CONFIRM)
		match _index:
			0:
				fade_in_location_menu()
				set_current_selection(0)
				return
			1:
				pass
			2:
				pass
			3:
				get_tree().change_scene_to_file("res://Scenes/UI/OptionMenu.tscn")
				return
			4:
				get_tree().quit()
	elif current_state == MenuState.LOCATION_SELECT:
		if (_index == 3):
			SoundManager.play_sfx(SFX_CONFIRM)
			fade_in_main_menu()
			set_current_selection(0)
			return
		
		var location_name = GameManager.Location.keys()[_index]
		
		if GameManager.is_location_locked(location_name):
			print("Location bloccata:", location_name)
			return
		
		# Se è sbloccata, procedi
		GameManager.location_selected = GameManager.Location.values()[_index]
		SoundManager.play_sfx(SFX_CONFIRM)
		
		if (_index == 0):
			get_tree().change_scene_to_file("res://Scenes/UI/LevelMenu.tscn")
		elif (_index == 1):
			get_tree().change_scene_to_file("res://Scenes/UI/LevelMenu.tscn")
		elif (_index == 2):
			get_tree().change_scene_to_file("res://Scenes/UI/LevelMenu.tscn")

func fade_in_main_menu():
	current_state = MenuState.MAIN_MENU
	update_active_menu()
	
	call_deferred("rebuild_base_positions")
	
	# Forza visibilità prima di settare l'indice
	for group in selectors:
		for sel in group:
			sel.visible = true
	
	current_selection = 0
	set_current_selection(current_selection)
	
	var main_container = $MenuContainer
	var location_container = $LocationContainer
	
	main_container.modulate.a = 0
	main_container.visible = true
	
	var tween = create_tween()
	tween.tween_property(location_container, "modulate:a", 0, 0.6)
	tween.tween_property(main_container, "modulate:a", 1, 0.6)
	location_container.visible = false

func fade_in_location_menu():
	current_state = MenuState.LOCATION_SELECT
	update_active_menu()
	
	call_deferred("rebuild_base_positions")
	
	for group in selectors:
		for sel in group:
			sel.visible = true
	
	current_selection = 0
	set_current_selection(current_selection)
	
	var main_container = $MenuContainer
	var location_container = $LocationContainer
	
	location_container.modulate.a = 0
	location_container.visible = true
	
	var tween = create_tween()
	tween.tween_property(main_container, "modulate:a", 0, 0.6)
	tween.tween_property(location_container, "modulate:a", 1, 0.6)
	main_container.visible = false
