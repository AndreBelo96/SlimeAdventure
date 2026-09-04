extends SelectableMenuPanel
class_name LocationMenuPanel

signal back_pressed
signal location_chosen(location)

func setup_languages() -> void:
	$LocationContainer/VBoxContainer/CenterContainer/Title.text = tr("LOCATION_TITLE")
	$LocationContainer/VBoxContainer/CenterContainer3/HBoxContainer/Button/Back.text = tr("BACK_BTN")
	$LocationContainer/VBoxContainer/CenterContainer2/LocationContainer/VBoxContainer2/Dungeon.text = tr("DUNGEON_BTN")
	$LocationContainer/VBoxContainer/CenterContainer2/LocationContainer/VBoxContainer3/Forest.text = tr("FOREST_BTN")

func setup_buttons() -> void:
	buttons = [
		$LocationContainer/VBoxContainer/CenterContainer2/LocationContainer/VBoxContainer/Tutorial,
		$LocationContainer/VBoxContainer/CenterContainer2/LocationContainer/VBoxContainer2/Dungeon,
		$LocationContainer/VBoxContainer/CenterContainer2/LocationContainer/VBoxContainer3/Forest,
		$LocationContainer/VBoxContainer/CenterContainer3/HBoxContainer/Button,
	]

func setup_selectors() -> void:
	selectors = [
		[$LocationContainer/VBoxContainer/CenterContainer2/LocationContainer/VBoxContainer/Control/Selector],
		[$LocationContainer/VBoxContainer/CenterContainer2/LocationContainer/VBoxContainer2/Control/Selector],
		[$LocationContainer/VBoxContainer/CenterContainer2/LocationContainer/VBoxContainer3/Control/Selector],
		[$LocationContainer/VBoxContainer/CenterContainer3/HBoxContainer/SelectorL, $LocationContainer/VBoxContainer/CenterContainer3/HBoxContainer/SelectorR],
	]

func handle_navigation(_event: InputEvent) -> void:
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

func handle_selection(index: int) -> void:
	if index == 3:
		SoundManager.play_sfx(SFX_CONFIRM)
		back_pressed.emit()
		return
	var location_name = LocationManager.Location.keys()[index]
	if LocationManager.is_location_locked(location_name):
		GameLogger.warn("Location bloccata: %s" % location_name)
		return
	SoundManager.play_sfx(SFX_CONFIRM)
	LocationManager.location_selected = LocationManager.Location.values()[index]
	location_chosen.emit(LocationManager.location_selected)   # <-- invece di change_scene_to_file

func update_location_buttons() -> void:
	var locations = LocationManager.Location.keys()
	for i in range(buttons.size()):
		if i >= locations.size():
			continue
		buttons[i].disabled = LocationManager.is_location_locked(locations[i])

func activate(start_index: int = 0) -> void:
	update_location_buttons()
	super.activate(start_index)
