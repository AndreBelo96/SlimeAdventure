extends SelectableMenu

@onready var pause: Label = $MarginContainer/VBoxContainer/Pausa
@onready var continueBtn: Label = $MarginContainer/VBoxContainer/CenterContainer/HBoxContainer/Continue/Continue
@onready var retry: Label = $MarginContainer/VBoxContainer/CenterContainer2/HBoxContainer/Retry/Retry
@onready var mainMenu: Label = $MarginContainer/VBoxContainer/CenterContainer3/HBoxContainer/MainMenu/MainMenu

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	setup_languages()
	setup_buttons()
	setup_selectors()
	_connect_mouse()

func setup_languages():
	pause.text = tr("PAUSE_LBL")
	continueBtn.text = tr("CONTINUE_BTN")
	retry.text = tr("RETRY_BTN")
	mainMenu.text = tr("BACK_MAIN_MENU_BTN")

func setup_buttons():
	buttons = [
		$MarginContainer/VBoxContainer/CenterContainer/HBoxContainer/Continue,
		$MarginContainer/VBoxContainer/CenterContainer2/HBoxContainer/Retry,
		$MarginContainer/VBoxContainer/CenterContainer3/HBoxContainer/MainMenu
	]

func setup_selectors():
	selectors = [
		[$MarginContainer/VBoxContainer/CenterContainer/HBoxContainer/SelectorL, $MarginContainer/VBoxContainer/CenterContainer/HBoxContainer/SelectorR],
		[$MarginContainer/VBoxContainer/CenterContainer2/HBoxContainer/SelectorL, $MarginContainer/VBoxContainer/CenterContainer2/HBoxContainer/SelectorR],
		[$MarginContainer/VBoxContainer/CenterContainer3/HBoxContainer/SelectorL, $MarginContainer/VBoxContainer/CenterContainer3/HBoxContainer/SelectorR],
	]

func handle_selection(_index):
	SoundManager.play_sfx(SFX_CONFIRM)
	if (_index == 0):
		get_tree().paused = false
		visible = false
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	elif (_index == 1):
		get_tree().paused = false
		visible = false
		SceneNavigator.restart_level(LevelStateManager.current_level)
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	elif (_index == 2):
		get_tree().paused = false
		SoundManager.stop_music();
		SceneNavigator.return_to_menu()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_pause_visible():
	if !visible:
		return

	await get_tree().process_frame
	await get_tree().process_frame

	calibrate_positions()
	set_current_selection(0)
