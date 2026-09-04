extends SelectableMenuPanel
class_name SaveMenuPanel

enum SubState { SLOT_SELECT, SLOT_ACTIONS }

signal back_pressed
signal play_pressed

@onready var container_data := $SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer
@onready var lastPlayedLbl := $SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/DataContainer/LastPlayed
@onready var playTimeLbl := $SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/DataContainer/PlayTime
@onready var lvlReachLbl := $SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/DataContainer/LvlReach

var sub_state: SubState = SubState.SLOT_SELECT
var slot_selected := 0

var buttons_slots: Array[Button] = []
var selectors_slots: Array = []

var buttons_actions_full: Array[Button] = []
var buttons_actions_empty: Array[Button] = []
var selectors_actions_full: Array = []
var selectors_actions_empty: Array = []
var buttons_actions: Array[Button] = []
var selectors_actions: Array = []

func setup_languages() -> void:
	$SaveSelectContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer5/HBoxContainer/Button/Back.text = tr("BACK_BTN")
	$SaveSelectContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer/HBoxContainer/Button/Save1.text = "%s 1" % tr("SAVE_LINE")
	$SaveSelectContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer2/HBoxContainer/Button/Save2.text = "%s 2" % tr("SAVE_LINE")
	$SaveSelectContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer3/HBoxContainer/Button/Save3.text = "%s 3" % tr("SAVE_LINE")
	$SaveSelectContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer4/HBoxContainer/Button/Save4.text = "%s 4" % tr("SAVE_LINE")

	$SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/BtnContainer/HBoxContainer/Button/Play.text = tr("PLAY_BTN")
	$SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/BtnContainer/HBoxContainer2/Button/Delete.text = tr("DELETE_BTN")
	$SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/BtnContainer/HBoxContainer3/Button/Back.text = tr("BACK_BTN")
	lastPlayedLbl.text = tr("LAST_PLAYED")
	playTimeLbl.text = tr("PLAY_TIME")
	lvlReachLbl.text = tr("LEVEL_MAX")

func setup_buttons() -> void:
	buttons_slots = [
		$SaveSelectContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer/HBoxContainer/Button,
		$SaveSelectContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer2/HBoxContainer/Button,
		$SaveSelectContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer3/HBoxContainer/Button,
		$SaveSelectContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer4/HBoxContainer/Button,
		$SaveSelectContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer5/HBoxContainer/Button,
	]

	var btn_play = $SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/BtnContainer/HBoxContainer/Button
	var btn_delete = $SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/BtnContainer/HBoxContainer2/Button
	var btn_back = $SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/BtnContainer/HBoxContainer3/Button
	btn_play.set_meta("action", "play")
	btn_delete.set_meta("action", "delete")
	btn_back.set_meta("action", "back")

	buttons_actions_full = [btn_play, btn_delete, btn_back]
	buttons_actions_empty = [btn_play, btn_back]
	buttons_actions = buttons_actions_full

	buttons = buttons_slots

func setup_selectors() -> void:
	selectors_slots = [
		[$SaveSelectContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer/HBoxContainer/SelectorL, $SaveSelectContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer/HBoxContainer/SelectorR],
		[$SaveSelectContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer2/HBoxContainer/SelectorL, $SaveSelectContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer2/HBoxContainer/SelectorR],
		[$SaveSelectContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer3/HBoxContainer/SelectorL, $SaveSelectContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer3/HBoxContainer/SelectorR],
		[$SaveSelectContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer4/HBoxContainer/SelectorL, $SaveSelectContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer4/HBoxContainer/SelectorR],
		[$SaveSelectContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer5/HBoxContainer/SelectorL, $SaveSelectContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer5/HBoxContainer/SelectorR],
	]

	var sel_play = [
		$SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/BtnContainer/HBoxContainer/SelectorL,
		$SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/BtnContainer/HBoxContainer/SelectorR,
	]
	var sel_delete = [
		$SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/BtnContainer/HBoxContainer2/SelectorL,
		$SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/BtnContainer/HBoxContainer2/SelectorR,
	]
	var sel_back = [
		$SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/BtnContainer/HBoxContainer3/SelectorL,
		$SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/BtnContainer/HBoxContainer3/SelectorR,
	]
	selectors_actions_full = [sel_play, sel_delete, sel_back]
	selectors_actions_empty = [sel_play, sel_back]
	selectors_actions = selectors_actions_full

	selectors = selectors_slots

	await get_tree().process_frame
	store_base_positions()
	for group in selectors_actions:
		for sel in group:
			base_positions[sel] = sel.position

func handle_selection(index: int) -> void:
	if sub_state == SubState.SLOT_SELECT:
		_handle_slot_selection(index)
	else:
		_handle_action_selection(index)

func _handle_slot_selection(index: int) -> void:
	SoundManager.play_sfx(SFX_CONFIRM)
	if index == 4:
		back_pressed.emit()
		return

	slot_selected = index
	LevelStateManager.current_save_slot = index + 1
	SaveManager.current_slot = index + 1
	SaveManager.load_progress()
	LevelStateManager.reload_save_data()

	_enter_slot_actions()

func _handle_action_selection(index: int) -> void:
	SoundManager.play_sfx(SFX_CONFIRM)
	var action = buttons_actions[index].get_meta("action")
	match action:
		"play":
			play_pressed.emit()
			return
		"delete":
			_confirm_delete()
			return
		"back":
			_enter_slot_select()

func _enter_slot_actions() -> void:
	sub_state = SubState.SLOT_ACTIONS
	container_data.visible = true
	update_save_data_panel(slot_selected + 1)

	buttons = buttons_actions
	selectors = selectors_actions
	call_deferred("rebuild_base_positions")
	for group in selectors:
		for sel in group:
			sel.visible = true
	current_selection = 0
	set_current_selection(current_selection)

func _enter_slot_select() -> void:
	sub_state = SubState.SLOT_SELECT
	container_data.visible = false

	buttons = buttons_slots
	selectors = selectors_slots
	call_deferred("rebuild_base_positions")
	for group in selectors:
		for sel in group:
			sel.visible = true
	current_selection = slot_selected
	set_current_selection(current_selection)

func activate(start_index: int = 0) -> void:
	sub_state = SubState.SLOT_SELECT
	container_data.visible = false
	buttons = buttons_slots
	selectors = selectors_slots
	super.activate(start_index)

## ---- Dati salvataggio ---- ##
func update_save_data_panel(slot: int) -> void:
	var data = SaveManager.get_slot_preview(slot)
	if data.get("levels", {}).is_empty():
		_show_empty_slot()
		return

	$SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/BtnContainer/HBoxContainer2.visible = true
	buttons_actions = buttons_actions_full
	selectors_actions = selectors_actions_full

	var max_level = data.get("max_level_reach", 1)
	var last_played = _format_date_smart(data.get("last_played", 0))
	var playtime = _format_time(data.get("total_time", 0.0))

	$SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/Title.text = tr("SAVE_LINE") + " %d" % slot + " - %d" % _get_completion_percent(data) + "%"
	lastPlayedLbl.text = tr("LAST_PLAYED") + ": " + last_played
	playTimeLbl.text = tr("PLAY_TIME") + ": %s" % playtime
	lvlReachLbl.text = tr("LEVEL_MAX") + ": %d" % max_level

func _show_empty_slot() -> void:
	$SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/Title.text = "Empty Slot"
	lastPlayedLbl.text = tr("LAST_PLAYED") + ": - "
	playTimeLbl.text = tr("PLAY_TIME") + ": - "
	lvlReachLbl.text = tr("LEVEL_MAX") + ": - "

	$SaveSelectContainer/VBoxContainer/HBoxContainer/SaveDataContainer/Panel/VBoxContainer/BtnContainer/HBoxContainer2.visible = false
	buttons_actions = buttons_actions_empty
	selectors_actions = selectors_actions_empty

	if sub_state == SubState.SLOT_ACTIONS:
		buttons = buttons_actions
		selectors = selectors_actions
		current_selection = 0
		set_current_selection(current_selection)

func _format_time(seconds: float) -> String:
	var total := int(seconds)
	@warning_ignore("integer_division")
	var hours := int(total / 3600)
	@warning_ignore("integer_division")
	var minutes := (total % 3600) / 60
	var secs := total % 60
	return "%02d:%02d:%02d" % [hours, minutes, secs]

func _format_date_smart(unix_time: int) -> String:
	if unix_time == 0:
		return "-"

	@warning_ignore("narrowing_conversion")
	var now_dict = Time.get_datetime_dict_from_unix_time(Time.get_unix_time_from_system())
	var date_dict = Time.get_datetime_dict_from_unix_time(unix_time)

	if now_dict.year == date_dict.year and now_dict.month == date_dict.month and now_dict.day == date_dict.day:
		return "Today"

	var yesterday = Time.get_unix_time_from_system() - 86400
	var y_dict = Time.get_datetime_dict_from_unix_time(yesterday)
	if y_dict.year == date_dict.year and y_dict.month == date_dict.month and y_dict.day == date_dict.day:
		return "Yesterday"

	return "%02d/%02d/%d" % [date_dict.day, date_dict.month, date_dict.year]

func _get_completion_percent(data: Dictionary) -> int:
	var completed = data.get("levels", {}).size()
	var total_levels = LocationManager.NUMBER_OF_LEVELS
	return int((completed / float(total_levels)) * 100)

## ---- Delete ---- ##
func _confirm_delete() -> void:
	input_enabled = false
	var dialog_scene = load("res://Scenes/UI/DeleteDialog.tscn")
	var dialog = dialog_scene.instantiate()
	add_child(dialog)
	dialog.visible = true
	dialog.confirmed.connect(_on_delete_confirmed)
	dialog.canceled.connect(_on_delete_canceled)

func _on_delete_confirmed() -> void:
	SaveManager.delete_slot(LevelStateManager.current_save_slot)
	SaveManager.load_progress()
	LevelStateManager.reload_save_data()
	input_enabled = true
	update_save_data_panel(LevelStateManager.current_save_slot)

func _on_delete_canceled() -> void:
	input_enabled = true
