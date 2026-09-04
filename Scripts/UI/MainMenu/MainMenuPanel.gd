extends SelectableMenuPanel
class_name MainMenuPanel

signal start_pressed
signal option_pressed
signal exit_pressed

func setup_languages() -> void:
	$MenuContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer/HBoxContainer/Button/Start.text = tr("START_BTN")
	$MenuContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer2/HBoxContainer/Button/Profile.text = tr("PROFILE_BTN")
	$MenuContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer3/HBoxContainer/Button/Scoreboard.text = tr("SCOREBOARD_BTN")
	$MenuContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer4/HBoxContainer/Button/Option.text = tr("OPTIONS_BTN")
	$MenuContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer5/HBoxContainer/Button/Exit.text = tr("EXIT_BTN")

func setup_buttons() -> void:
	buttons = [
		$MenuContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer/HBoxContainer/Button,
		$MenuContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer2/HBoxContainer/Button,
		$MenuContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer3/HBoxContainer/Button,
		$MenuContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer4/HBoxContainer/Button,
		$MenuContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer5/HBoxContainer/Button,
	]

func setup_selectors() -> void:
	selectors = [
		[$MenuContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer/HBoxContainer/SelectorL, $MenuContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer/HBoxContainer/SelectorR],
		[$MenuContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer2/HBoxContainer/SelectorL, $MenuContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer2/HBoxContainer/SelectorR],
		[$MenuContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer3/HBoxContainer/SelectorL, $MenuContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer3/HBoxContainer/SelectorR],
		[$MenuContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer4/HBoxContainer/SelectorL, $MenuContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer4/HBoxContainer/SelectorR],
		[$MenuContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer5/HBoxContainer/SelectorL, $MenuContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer5/HBoxContainer/SelectorR],
	]
	await get_tree().process_frame
	store_base_positions()

func handle_selection(index: int) -> void:
	SoundManager.play_sfx(SFX_CONFIRM)
	match index:
		0: start_pressed.emit()
		1: pass # Profile - TODO
		2: pass # Scoreboard - TODO
		3: option_pressed.emit()
		4: exit_pressed.emit()
