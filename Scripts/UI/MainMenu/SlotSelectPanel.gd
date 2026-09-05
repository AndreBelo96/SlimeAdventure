extends SelectableMenuPanel
class_name SlotSelectPanel

signal slot_chosen(index: int)
signal back_pressed

func setup_languages() -> void:
	$SlotSelectPanel/CenterContainer5/HBoxContainer/Button/Back.text = tr("BACK_BTN")
	$SlotSelectPanel/CenterContainer/HBoxContainer/Button/Save1.text = "%s 1" % tr("SAVE_LINE")
	$SlotSelectPanel/CenterContainer2/HBoxContainer/Button/Save2.text = "%s 2" % tr("SAVE_LINE")
	$SlotSelectPanel/CenterContainer3/HBoxContainer/Button/Save3.text = "%s 3" % tr("SAVE_LINE")
	$SlotSelectPanel/CenterContainer4/HBoxContainer/Button/Save4.text = "%s 4" % tr("SAVE_LINE")

func setup_buttons() -> void:
	buttons = [
		$SlotSelectPanel/CenterContainer/HBoxContainer/Button,
		$SlotSelectPanel/CenterContainer2/HBoxContainer/Button,
		$SlotSelectPanel/CenterContainer3/HBoxContainer/Button,
		$SlotSelectPanel/CenterContainer4/HBoxContainer/Button,
		$SlotSelectPanel/CenterContainer5/HBoxContainer/Button,
	]

func setup_selectors() -> void:
	selectors = [
		[$SlotSelectPanel/CenterContainer/HBoxContainer/SelectorL, $SlotSelectPanel/CenterContainer/HBoxContainer/SelectorR],
		[$SlotSelectPanel/CenterContainer2/HBoxContainer/SelectorL, $SlotSelectPanel/CenterContainer2/HBoxContainer/SelectorR],
		[$SlotSelectPanel/CenterContainer3/HBoxContainer/SelectorL, $SlotSelectPanel/CenterContainer3/HBoxContainer/SelectorR],
		[$SlotSelectPanel/CenterContainer4/HBoxContainer/SelectorL, $SlotSelectPanel/CenterContainer4/HBoxContainer/SelectorR],
		[$SlotSelectPanel/CenterContainer5/HBoxContainer/SelectorL, $SlotSelectPanel/CenterContainer5/HBoxContainer/SelectorR],
	]

func handle_selection(index: int) -> void:
	SoundManager.play_sfx(SFX_CONFIRM)
	if index == 4:
		back_pressed.emit()
		return
	slot_chosen.emit(index)
