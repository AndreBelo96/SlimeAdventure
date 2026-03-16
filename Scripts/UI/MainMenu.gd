extends BaseMenu

@onready var container_data := $SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer

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

func setup_save_buttons():
	buttons_save = [
		$SaveSelectContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer/HBoxContainer/Button,
		$SaveSelectContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer2/HBoxContainer/Button,
		$SaveSelectContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer3/HBoxContainer/Button,
		$SaveSelectContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer4/HBoxContainer/Button,
		$SaveSelectContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer5/HBoxContainer/Button
	]

func setup_save_data_buttons():
	buttons_save_data = [
		$SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/BtnContainer/HBoxContainer/Button,
		$SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/BtnContainer/HBoxContainer2/Button,
		$SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/BtnContainer/HBoxContainer3/Button
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

func setup_save_selectors():
	selectors_save  = [
		[$SaveSelectContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer/HBoxContainer/SelectorL, $SaveSelectContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer/HBoxContainer/SelectorR],
		[$SaveSelectContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer2/HBoxContainer/SelectorL, $SaveSelectContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer2/HBoxContainer/SelectorR],
		[$SaveSelectContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer3/HBoxContainer/SelectorL, $SaveSelectContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer3/HBoxContainer/SelectorR],
		[$SaveSelectContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer4/HBoxContainer/SelectorL, $SaveSelectContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer4/HBoxContainer/SelectorR],
		[$SaveSelectContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer5/HBoxContainer/SelectorL, $SaveSelectContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer5/HBoxContainer/SelectorR],
	]
	
	await get_tree().process_frame
	for group in selectors_save:
		for sel in group:
			base_positions[sel] = sel.position

func setup_save_data_selectors():
	selectors_save_data  = [
		[$SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/BtnContainer/HBoxContainer/SelectorL, $SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/BtnContainer/HBoxContainer/SelectorR],
		[$SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/BtnContainer/HBoxContainer2/SelectorL, $SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/BtnContainer/HBoxContainer2/SelectorR],
		[$SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/BtnContainer/HBoxContainer3/SelectorL, $SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/BtnContainer/HBoxContainer3/SelectorR],
	]
	
	await get_tree().process_frame
	for group in selectors_save_data:
		for sel in group:
			base_positions[sel] = sel.position

## ----- Handle btn ----- ##
func handle_navigation(_event):
	if current_state in [MenuState.MAIN_MENU, MenuState.SAVE_MENU, MenuState.SAVE_SLOT_ACTIONS]:
		var delta := 0
		if Input.is_action_just_pressed("move_down"):
			delta = 1
		elif Input.is_action_just_pressed("move_up"):
			delta = -1
		
		if delta != 0:
			SoundManager.play_sfx(SFX_MOVE)
			change_selection(delta)
	elif current_state == MenuState.LOCATION_SELECT:
		var new_selection := current_selection

		if Input.is_action_just_pressed("move_right") and current_selection < 3:
			new_selection += 1
		elif Input.is_action_just_pressed("move_left") and current_selection > 0:
			new_selection -= 1
		elif Input.is_action_just_pressed("move_down") and current_selection < 3:
			new_selection = 3
		elif Input.is_action_just_pressed("move_up") and current_selection > 0:
			new_selection = 0

		if new_selection != current_selection:
			SoundManager.play_sfx(SFX_MOVE)
			current_selection = new_selection
			set_current_selection(current_selection)

func change_selection(delta):
	current_selection += delta
	current_selection = clamp(current_selection, 0, buttons.size() - 1)
	set_current_selection(current_selection)

## ----- Selction btn ----- ##
func handle_selection(_index):
	if not input_enabled:
		return
	if current_state == MenuState.MAIN_MENU:
		handle_main_menu_selection(_index)
	elif current_state == MenuState.SAVE_MENU:
		handle_save_menu_selection(_index)
	elif current_state == MenuState.SAVE_SLOT_ACTIONS:
		handle_save_data_menu_selection(_index)
	elif current_state == MenuState.LOCATION_SELECT:
		handle_location_selection(_index)

func handle_main_menu_selection(index):
	SoundManager.play_sfx(SFX_CONFIRM)
	match index:
		0:
			container_data.visible = false
			fade_in_save_menu()
		1:
			pass
		2:
			pass
		3:
			get_tree().change_scene_to_file("res://Scenes/UI/OptionMenu.tscn")
		4:
			get_tree().quit()
	set_current_selection(0)

func handle_save_menu_selection(index):
	SoundManager.play_sfx(SFX_CONFIRM)
	if index == 4:
		fade_in_main_menu()
		return
	GameManager.current_save_slot = index + 1
	SaveManager.current_slot = index + 1
	SaveManager.load_progress()
	GameManager.reload_save_data()
	current_state = MenuState.SAVE_SLOT_ACTIONS
	update_save_data_panel(index+1)
	container_data.visible = true
	set_current_selection(0)

func handle_save_data_menu_selection(index):
	SoundManager.play_sfx(SFX_CONFIRM)
	match index:
		0:
			container_data.visible = false
			fade_in_location_menu()
			return
		1:
			input_enabled = false
			SaveManager.delete_slot(GameManager.current_save_slot)
		2:
			input_enabled = false
			
	current_state = MenuState.SAVE_MENU
	container_data.visible = false
	update_active_menu()
	call_deferred("rebuild_base_positions")
	for group in selectors:
		for sel in group:
			sel.visible = true
	current_selection = 0
	set_current_selection(current_selection)
	input_enabled = true

func handle_location_selection(index):

	if index == 3:
		SoundManager.play_sfx(SFX_CONFIRM)
		fade_in_save_menu()
		set_current_selection(0)
		return

	var location_name = GameManager.Location.keys()[index]

	if GameManager.is_location_locked(location_name):
		print("Location bloccata:", location_name)
		return

	SoundManager.play_sfx(SFX_CONFIRM)

	GameManager.location_selected = GameManager.Location.values()[index]

	get_tree().change_scene_to_file("res://Scenes/UI/LevelMenu.tscn")

## ----- Fade in/out btn ----- ##
func fade_in_main_menu():
	await switch_menu(MenuState.MAIN_MENU, $MenuContainer)

func fade_in_save_menu():
	await switch_menu(MenuState.SAVE_MENU, $SaveSelectContainer)

func fade_in_location_menu():
	await switch_menu(MenuState.LOCATION_SELECT, $LocationContainer)

func switch_menu(state: MenuState, container: Control):
	current_state = state
	update_active_menu()
	call_deferred("rebuild_base_positions")
	for group in selectors:
		for sel in group:
			sel.visible = true
	current_selection = 0
	set_current_selection(current_selection)
	await fade_to(container)

func fade_to(target: Control):
	input_enabled = false
	var containers = [
		$MenuContainer,
		$SaveSelectContainer,
		$LocationContainer
	]
	target.modulate.a = 0
	target.visible = true
	
	var tween = create_tween()
	for c in containers:
		if c == target:
			tween.parallel().tween_property(c, "modulate:a", 1, 0.3)
		else:
			tween.parallel().tween_property(c, "modulate:a", 0, 0.1)
	for c in containers:
		if c != target:
			c.visible = false
	await tween.finished
	input_enabled = true

## ---- Update Data ---- ##
func update_save_data_panel(slot:int):
	var data = SaveManager.get_slot_preview(slot)
	if data.get("levels", {}).is_empty():
		show_empty_slot()
		return

	var totals = {
		"steps": data.get("total_steps", 0),
		"time": data.get("total_time", 0.0),
		"deaths": data.get("death_counts", {})
	}

	var max_level = data.get("max_level_reach", 1)
	var deaths_total := 0
	for d in totals.deaths.values():
		deaths_total += int(d)
	var playtime = format_time(totals.time)
	
	$SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/Title.text = "Save slot %d" % slot
	$SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/DataContainer/LvlReach.text = "Level Reached: %d" % max_level
	$SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/DataContainer/PlayTime.text = "Playtime: %s" % playtime
	$SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/DataContainer/Steps.text = "Steps: %d" % totals.steps
	$SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/DataContainer/Deaths.text = "Deaths: %d" % deaths_total

func show_empty_slot():
	$SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/Title.text = "Empty Slot"
	$SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/DataContainer/LvlReach.text = "-"
	$SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/DataContainer/PlayTime.text = "-"
	$SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/DataContainer/Steps.text = "-"
	$SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/DataContainer/Deaths.text = "-"

func format_time(seconds:float) -> String:
	var total = int(seconds)
	var hours = total / 3600
	var minutes = (total % 3600) / 60
	var secs = total % 60
	return "%02d:%02d:%02d" % [hours, minutes, secs]
