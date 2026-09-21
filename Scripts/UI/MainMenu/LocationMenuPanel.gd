extends SelectableMenuPanel
class_name LocationMenuPanel

signal back_pressed
signal location_chosen(location)
signal profile_pressed

@onready var profile_btn: BtnTheme = $LocationContainer/VBoxContainer/CenterContainer3/HBoxContainer/Profile
@onready var back_btn: BtnTheme = $LocationContainer/VBoxContainer/CenterContainer3/HBoxContainer/Back

func setup_languages() -> void:
	$LocationContainer/VBoxContainer/CenterContainer/Title.text = tr("LOCATION_TITLE")
	back_btn.set_text(tr("BACK_BTN"))
	back_btn.set_font_size(22)
	profile_btn.set_text(tr("PROFILE_BTN"))
	profile_btn.set_font_size(22)
	$LocationContainer/VBoxContainer/CenterContainer2/LocationContainer/VBoxContainer2/Dungeon.text = tr("DUNGEON_BTN")
	$LocationContainer/VBoxContainer/CenterContainer2/LocationContainer/VBoxContainer3/Forest.text = tr("FOREST_BTN")

func setup_buttons() -> void:
	buttons = [
		$LocationContainer/VBoxContainer/CenterContainer2/LocationContainer/VBoxContainer/Tutorial,
		$LocationContainer/VBoxContainer/CenterContainer2/LocationContainer/VBoxContainer2/Dungeon,
		$LocationContainer/VBoxContainer/CenterContainer2/LocationContainer/VBoxContainer3/Forest,
		back_btn.button,
		profile_btn.button
	]

func setup_selectors() -> void:
	selectors = [
		[$LocationContainer/VBoxContainer/CenterContainer2/LocationContainer/VBoxContainer/Control/Selector],
		[$LocationContainer/VBoxContainer/CenterContainer2/LocationContainer/VBoxContainer2/Control/Selector],
		[$LocationContainer/VBoxContainer/CenterContainer2/LocationContainer/VBoxContainer3/Control/Selector],
		back_btn.get_selector_group(),
		profile_btn.get_selector_group()
	]

func handle_navigation(_event: InputEvent) -> void:
	var new_selection := current_selection
	if current_selection < 3:
		# riga sopra: Tutorial(0) Dungeon(1) Forest(2)
		if Input.is_action_just_pressed("move_right") and current_selection < 2:
			new_selection += 1
		elif Input.is_action_just_pressed("move_left") and current_selection > 0:
			new_selection -= 1
		elif Input.is_action_just_pressed("move_down"):
			new_selection = 4  # Profile, a sinistra nella riga sotto
	else:
		# riga sotto: Profile(4) a sinistra, Back(3) a destra
		if Input.is_action_just_pressed("move_right") and current_selection == 4:
			new_selection = 3
		elif Input.is_action_just_pressed("move_left") and current_selection == 3:
			new_selection = 4
		elif Input.is_action_just_pressed("move_up"):
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
	if index == 4:
		SoundManager.play_sfx(SFX_CONFIRM)
		profile_pressed.emit()
		return
	var location_name = LocationManager.Location.keys()[index]
	if LocationManager.is_location_locked(location_name):
		GameLogger.warn("Location bloccata: %s" % location_name)
		return
	SoundManager.play_sfx(SFX_CONFIRM)
	LocationManager.location_selected = LocationManager.Location.values()[index]
	location_chosen.emit(LocationManager.location_selected)

func update_location_buttons() -> void:
	var locations = LocationManager.Location.keys()
	for i in range(buttons.size()):
		if i >= locations.size():
			continue
		buttons[i].disabled = LocationManager.is_location_locked(locations[i])

func activate(start_index: int = 0) -> void:
	update_location_buttons()
	super.activate(start_index)
