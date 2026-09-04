extends SelectableMenuPanel
class_name LevelMenuPanel

signal back_pressed

const ROW_SIZE := 5

@onready var level_container: GridContainer = $MarginContainer/VBoxContainer/CenterContainer2/LevelButtonContainer
@onready var location_lbl: Label = $MarginContainer/VBoxContainer/CenterContainer4/Location
@onready var title_lbl: Label = $MarginContainer/VBoxContainer/CenterContainer/Title
@onready var back_button: Button = $MarginContainer/VBoxContainer/CenterContainer3/HBoxContainer/Button
@onready var back_selector: Array = [
	$MarginContainer/VBoxContainer/CenterContainer3/HBoxContainer/SelectorL,
	$MarginContainer/VBoxContainer/CenterContainer3/HBoxContainer/SelectorR,
]

var loader = LevelLoader.new()
var factory = LevelButtonFactory.new()
var _back_connected := false

func setup_languages() -> void:
	title_lbl.text = tr("LVL_SELECTION_LBL")
	back_button.get_node("Back").text = tr("BACK_BTN")  # adatta il path se il Label si chiama diversamente

## setup_buttons/setup_selectors restano vuoti: qui i bottoni sono dinamici,
## vengono creati da _reload_level_buttons() ad ogni activate().
func setup_buttons() -> void:
	pass
func setup_selectors() -> void:
	pass

## Non usiamo il _connect_mouse generico della base (collegherebbe un array
## vuoto in _ready, prima che qualunque bottone esista): i bottoni dinamici
## si collegano da soli in _reload_level_buttons().
func _connect_mouse() -> void:
	pass

func activate(start_index: int = 0) -> void:
	await _reload_level_buttons()
	super.activate(start_index)

func _reload_level_buttons() -> void:
	for child in level_container.get_children():
		child.queue_free()

	buttons.clear()
	selectors.clear()
	base_positions.clear()

	location_lbl.text = tr(LocationManager.location_translation_keys[LocationManager.location_selected])

	var levels_info = loader.get_level_data_for_location(LocationManager.location_selected)
	var levels_range = LocationManager.get_level_range_for_location(LocationManager.location_selected)

	for i in range(levels_info.size()):
		var info = levels_info[i]
		var relative_index = levels_range.find(loader.extract_level_number(info.path)) + 1
		var location_id = int(LocationManager.location_selected)
		var display_number = "%d.%d" % [location_id, relative_index]

		var container = factory.create_level_button(display_number, info.disabled, info.theme)
		level_container.add_child(container)

		var button = container.get_child(0) as Button
		var selector_control = container.get_child(1)
		var selector_label = selector_control.get_node("Selector") as Label

		if button == null or selector_label == null:
			push_warning("Level button factory structure mismatch at index %d" % i)
			continue

		buttons.append(button)
		selectors.append([selector_label])

		# collega mouse per QUESTO bottone appena creato (niente binding stantio:
		# viene ricreato ogni volta insieme al bottone stesso)
		button.mouse_entered.connect(_on_level_button_mouse_entered.bind(button))
		button.pressed.connect(_on_level_button_pressed.bind(button))

	buttons.append(back_button)
	selectors.append(back_selector)

	if not _back_connected:
		# il back_button è un nodo FISSO in scena, non va ricreato/ricollegato
		# ad ogni reload, altrimenti si accumulano connessioni duplicate
		back_button.mouse_entered.connect(_on_level_button_mouse_entered.bind(back_button))
		back_button.pressed.connect(_on_level_button_pressed.bind(back_button))
		_back_connected = true

	# aspetta che i Container finiscano il sort differito prima di leggere le posizioni
	await get_tree().process_frame
	await get_tree().process_frame
	for group in selectors:
		for sel in group:
			base_positions[sel] = sel.position

func _on_level_button_mouse_entered(btn: Button) -> void:
	var index = buttons.find(btn)
	if index == -1:
		return
	SoundManager.play_sfx(SFX_MOVE)
	current_selection = index
	set_current_selection(current_selection)

func _on_level_button_pressed(btn: Button) -> void:
	var index = buttons.find(btn)
	if index == -1:
		return
	handle_selection(index)

func is_level_disabled() -> bool:
	return current_selection + 1 > LevelStateManager.max_level_reach

func handle_navigation(_event: InputEvent) -> void:
	var max_index = buttons.size() - 1

	if Input.is_action_just_pressed("move_right") and current_selection < max_index:
		SoundManager.play_sfx(SFX_MOVE)
		current_selection += 1
	elif Input.is_action_just_pressed("move_left") and current_selection > 0:
		SoundManager.play_sfx(SFX_MOVE)
		current_selection -= 1
	elif Input.is_action_just_pressed("move_down") and current_selection < max_index:
		SoundManager.play_sfx(SFX_MOVE)
		current_selection = current_selection + ROW_SIZE if current_selection + ROW_SIZE <= max_index else max_index
	elif Input.is_action_just_pressed("move_up") and current_selection > 0:
		SoundManager.play_sfx(SFX_MOVE)
		current_selection = current_selection - ROW_SIZE if current_selection - ROW_SIZE >= 0 else 0

	set_current_selection(current_selection)

func handle_selection(index: int) -> void:
	if index == buttons.size() - 1:
		SoundManager.play_sfx(SFX_CONFIRM)
		back_pressed.emit()
		return

	if is_level_disabled():
		return

	var info = loader.get_level_data_for_location(LocationManager.location_selected)[index]
	_on_level_confirmed(info.path, info.sound)

func _on_level_confirmed(path: String, _sound: String) -> void:
	var level_num = loader.extract_level_number(path)
	LevelStateManager.current_level = level_num

	var is_first_level_of_location = level_num == LocationManager.get_level_range_for_location(LocationManager.location_selected)[0]

	SoundManager.stop_music()

	if is_first_level_of_location:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		var loader_scene = preload("res://Scenes/UI/TransitionScreen.tscn").instantiate()
		loader_scene.scene_to_load = path
		loader_scene.transition_text = LocationManager.Location.keys()[LocationManager.get_location_for_level(level_num)]
		loader_scene.location_id = int(LocationManager.get_location_for_level(level_num))
		get_tree().root.add_child(loader_scene)
	else:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		get_tree().change_scene_to_file(path)
