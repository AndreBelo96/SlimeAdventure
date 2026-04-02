extends BaseMenu

@onready var container_data := $SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer

var buttons_save_data_full : Array[Button] = []
var buttons_save_data_empty : Array[Button] = []
var selectors_save_data_full = []
var selectors_save_data_empty = []
var slot_selected = 0

func setup_languages():
	$MenuContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer/HBoxContainer/Button/Start.text = tr("START_BTN")
	$MenuContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer2/HBoxContainer/Button/Profile.text = tr("PROFILE_BTN")
	$MenuContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer3/HBoxContainer/Button/Scoreboard.text = tr("SCOREBOARD_BTN")
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
	var btn_play = $SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/BtnContainer/HBoxContainer/Button
	var btn_delete = $SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/BtnContainer/HBoxContainer2/Button
	var btn_back = $SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/BtnContainer/HBoxContainer3/Button
	
	btn_play.set_meta("action", "play")
	btn_delete.set_meta("action", "delete")
	btn_back.set_meta("action", "back")
	
	buttons_save_data_full = [btn_play, btn_delete, btn_back]
	buttons_save_data_empty = [btn_play, btn_back]
	
	# default
	buttons_save_data = buttons_save_data_full

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
	var sel_play = [
		$SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/BtnContainer/HBoxContainer/SelectorL, 
		$SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/BtnContainer/HBoxContainer/SelectorR
		]
	var sel_delete = [
		$SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/BtnContainer/HBoxContainer2/SelectorL, 
		$SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/BtnContainer/HBoxContainer2/SelectorR
		]
	var sel_back = [
		$SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/BtnContainer/HBoxContainer3/SelectorL, 
		$SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/BtnContainer/HBoxContainer3/SelectorR
		]
	
	selectors_save_data_full = [sel_play, sel_delete, sel_back]
	selectors_save_data_empty = [sel_play, sel_back]
	
	selectors_save_data = selectors_save_data_full
	
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
			fade_in_option_menu()
		4:
			get_tree().quit()

func handle_save_menu_selection(index):
	SoundManager.play_sfx(SFX_CONFIRM)
	if index == 4:
		fade_in_main_menu()
		return
	GameManager.current_save_slot = index + 1
	SaveManager.current_slot = index + 1
	SaveManager.load_progress()
	GameManager.reload_save_data()
	slot_selected = index
	current_state = MenuState.SAVE_SLOT_ACTIONS
	update_save_data_panel(index+1)
	
	update_active_menu()
	call_deferred("rebuild_base_positions")
	for group in selectors:
		for sel in group:
			sel.visible = true
	current_selection = 0
	set_current_selection(current_selection)
	input_enabled = true
	
	container_data.visible = true

func handle_save_data_menu_selection(index):
	SoundManager.play_sfx(SFX_CONFIRM)
	var btn = buttons_save_data[index]
	var action = btn.get_meta("action")
	match action:
		"play":
			container_data.visible = false
			fade_in_location_menu()
			update_location_buttons()
			return
		"delete":
			confirm_delete()
			return
		"back":
			input_enabled = false
	
	current_state = MenuState.SAVE_MENU
	container_data.visible = false
	update_active_menu()
	call_deferred("rebuild_base_positions")
	for group in selectors:
		for sel in group:
			sel.visible = true
	current_selection = slot_selected
	set_current_selection(current_selection)
	input_enabled = true

func handle_location_selection(index):

	if index == 3:
		SoundManager.play_sfx(SFX_CONFIRM)
		fade_in_save_menu()
		return

	var location_name = GameManager.Location.keys()[index]

	if GameManager.is_location_locked(location_name): #TODO far capire sono bloccate
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

func fade_in_option_menu():
	await switch_menu(MenuState.OPTION_MENU, $OptionMenu)

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
		$LocationContainer,
		$OptionMenu
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

func update_location_buttons():
	var locations = GameManager.Location.keys()
	
	for i in range(buttons_location.size()):
		var btn = buttons_location[i]
		
		# se è il back → skip
		if i >= locations.size():
			continue
		
		var location_name = locations[i]

		if GameManager.is_location_locked(location_name):
			btn.disabled = true
		else:
			btn.disabled = false

## ---- Update Data ---- ##
func update_save_data_panel(slot:int):
	var data = SaveManager.get_slot_preview(slot)
	if data.get("levels", {}).is_empty():
		show_empty_slot()
		return
	
	$SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/BtnContainer/HBoxContainer/Button/Play.text = "Continue"
	$SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/BtnContainer/HBoxContainer2.visible = true
	buttons_save_data = buttons_save_data_full
	selectors_save_data = selectors_save_data_full
	
	var totals = {
		"time": data.get("total_time", 0.0)
	}

	var max_level = data.get("max_level_reach", 1)
	var last_played = format_date_smart(data.get("last_played", 0))
	var playtime = format_time(totals.time)
	
	$SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/Title.text = "Save slot %d" % slot + " - %d" % get_completion_percent(data) + "%"
	$SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/DataContainer/LastPlayed.text = "Last Played: " + last_played
	$SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/DataContainer/PlayTime.text = "Playtime: %s" % playtime
	$SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/DataContainer/LvlReach.text = "Level Reached: %d" % max_level

func show_empty_slot():
	$SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/Title.text = "Empty Slot"
	$SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/DataContainer/LastPlayed.text = "Last Played: - "
	$SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/DataContainer/PlayTime.text = "Playtime: - "
	$SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/DataContainer/LvlReach.text = "Level Reached: - "
	
	$SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/BtnContainer/HBoxContainer/Button/Play.text = "New game"
	$SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/BtnContainer/HBoxContainer2.visible = false
	buttons_save_data = buttons_save_data_empty
	selectors_save_data = selectors_save_data_empty
	update_active_menu()
	current_selection = 0
	set_current_selection(current_selection)

func format_time(seconds:float) -> String:
	var total = int(seconds)
	@warning_ignore("integer_division")
	var hours = int(total / 3600)
	@warning_ignore("integer_division")
	var minutes = (total % 3600) / 60
	var secs = total % 60
	return "%02d:%02d:%02d" % [hours, minutes, secs]

func format_date_smart(unix_time:int) -> String:
	if unix_time == 0:
		return "-"

	@warning_ignore("narrowing_conversion")
	var now_dict = Time.get_datetime_dict_from_unix_time(Time.get_unix_time_from_system())
	var date_dict = Time.get_datetime_dict_from_unix_time(unix_time)

	if now_dict.year == date_dict.year \
	and now_dict.month == date_dict.month \
	and now_dict.day == date_dict.day:
		return "Today"

	# ieri
	var yesterday = Time.get_unix_time_from_system() - 86400
	var y_dict = Time.get_datetime_dict_from_unix_time(yesterday)

	if y_dict.year == date_dict.year \
	and y_dict.month == date_dict.month \
	and y_dict.day == date_dict.day:
		return "Yesterday"

	return "%02d/%02d/%d" % [
		date_dict.day,
		date_dict.month,
		date_dict.year
	]

func get_completion_percent(data: Dictionary) -> int:
	var completed = data.get("levels", {}).size()
	var total_levels = GameManager.NUMBER_OF_LEVELS
	
	return int((completed / float(total_levels)) * 100)

## ---- Delete ---- ##

func confirm_delete():
	input_enabled = false
	var dialog_scene = load("res://Scenes/UI/DeleteDialog.tscn")
	var dialog = dialog_scene.instantiate()
	add_child(dialog)
	dialog.visible = true
	dialog.confirmed.connect(_on_delete_confirmed)
	dialog.canceled.connect(_on_delete_canceled)


func _on_delete_confirmed():
	SaveManager.delete_slot(GameManager.current_save_slot)
	SaveManager.load_progress()
	GameManager.reload_save_data()
	input_enabled = true
	update_save_data_panel(GameManager.current_save_slot)

func _on_delete_canceled():
	input_enabled = true
