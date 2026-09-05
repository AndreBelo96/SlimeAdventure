extends SelectableMenuPanel
class_name SlotActionsPanel

signal play_pressed
signal back_pressed

@onready var lastPlayedLbl := $SlotActionsPanel/Panel/MarginContainer/VBoxContainer/DataContainer/LastPlayed
@onready var playTimeLbl := $SlotActionsPanel/Panel/MarginContainer/VBoxContainer/DataContainer/PlayTime
@onready var lvlReachLbl := $SlotActionsPanel/Panel/MarginContainer/VBoxContainer/DataContainer/LvlReach
@onready var title_lbl := $SlotActionsPanel/Panel/MarginContainer/VBoxContainer/Title

var buttons_full: Array[Button] = []
var buttons_empty: Array[Button] = []
var selectors_full: Array = []
var selectors_empty: Array = []
var current_slot := 1

func setup_languages() -> void:
	$SlotActionsPanel/Panel/MarginContainer/VBoxContainer/BtnContainer/HBoxContainer/Button/Play.text = tr("PLAY_BTN")
	$SlotActionsPanel/Panel/MarginContainer/VBoxContainer/BtnContainer/HBoxContainer2/Button/Delete.text = tr("DELETE_BTN")
	$SlotActionsPanel/Panel/MarginContainer/VBoxContainer/BtnContainer/HBoxContainer3/Button/Back.text = tr("BACK_BTN")
	lastPlayedLbl.text = tr("LAST_PLAYED")
	playTimeLbl.text = tr("PLAY_TIME")
	lvlReachLbl.text = tr("LEVEL_MAX")

func setup_buttons() -> void:
	var btn_play = $SlotActionsPanel/Panel/MarginContainer/VBoxContainer/BtnContainer/HBoxContainer/Button
	var btn_delete = $SlotActionsPanel/Panel/MarginContainer/VBoxContainer/BtnContainer/HBoxContainer2/Button
	var btn_back = $SlotActionsPanel/Panel/MarginContainer/VBoxContainer/BtnContainer/HBoxContainer3/Button
	btn_play.set_meta("action", "play")
	btn_delete.set_meta("action", "delete")
	btn_back.set_meta("action", "back")
	buttons_full = [btn_play, btn_delete, btn_back]
	buttons_empty = [btn_play, btn_back]
	buttons = buttons_full

func setup_selectors() -> void:
	var sel_play = [$SlotActionsPanel/Panel/MarginContainer/VBoxContainer/BtnContainer/HBoxContainer/SelectorL, $SlotActionsPanel/Panel/MarginContainer/VBoxContainer/BtnContainer/HBoxContainer/SelectorR]
	var sel_delete = [$SlotActionsPanel/Panel/MarginContainer/VBoxContainer/BtnContainer/HBoxContainer2/SelectorL, $SlotActionsPanel/Panel/MarginContainer/VBoxContainer/BtnContainer/HBoxContainer2/SelectorR]
	var sel_back = [$SlotActionsPanel/Panel/MarginContainer/VBoxContainer/BtnContainer/HBoxContainer3/SelectorL, $SlotActionsPanel/Panel/MarginContainer/VBoxContainer/BtnContainer/HBoxContainer3/SelectorR]
	selectors_full = [sel_play, sel_delete, sel_back]
	selectors_empty = [sel_play, sel_back]
	selectors = selectors_full

## Chiamato dal coordinatore PRIMA di activate(), per caricare i dati dello slot
func show_slot(slot: int) -> void:
	current_slot = slot
	update_save_data_panel(slot)

func handle_selection(index: int) -> void:
	SoundManager.play_sfx(SFX_CONFIRM)
	var action = buttons[index].get_meta("action")
	match action:
		"play":
			play_pressed.emit()
		"delete":
			_confirm_delete()
		"back":
			back_pressed.emit()

## ---- Dati salvataggio ---- ##
func update_save_data_panel(slot: int) -> void:
	var data = SaveManager.get_slot_preview(slot)
	if data.get("levels", {}).is_empty():
		_show_empty_slot()
		return
	$SlotActionsPanel/Panel/MarginContainer/VBoxContainer/BtnContainer/HBoxContainer2.visible = true
	buttons = buttons_full
	selectors = selectors_full

	var max_level = data.get("max_level_reach", 1)
	var last_played = _format_date_smart(data.get("last_played", 0))
	var playtime = _format_time(data.get("total_time", 0.0))

	title_lbl.text = tr("SAVE_LINE") + " %d" % slot + " - %d" % _get_completion_percent(data) + "%"
	lastPlayedLbl.text = tr("LAST_PLAYED") + ": " + last_played
	playTimeLbl.text = tr("PLAY_TIME") + ": %s" % playtime
	lvlReachLbl.text = tr("LEVEL_MAX") + ": %d" % max_level

	current_selection = 0
	set_current_selection(current_selection)

func _show_empty_slot() -> void:
	title_lbl.text = "Empty Slot"
	lastPlayedLbl.text = tr("LAST_PLAYED") + ": - "
	playTimeLbl.text = tr("PLAY_TIME") + ": - "
	lvlReachLbl.text = tr("LEVEL_MAX") + ": - "

	$Panel/MarginContainer/VBoxContainer/BtnContainer/HBoxContainer2.visible = false
	buttons = buttons_empty
	selectors = selectors_empty

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

## calibra sempre sul layout "full": è il superset di posizioni necessarie
func calibrate_positions() -> void:
	for group in selectors_full:
		for sel in group:
			base_positions[sel] = sel.position

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
	SaveManager.delete_slot(current_slot)
	SaveManager.load_progress()
	LevelStateManager.reload_save_data()
	input_enabled = true
	update_save_data_panel(current_slot)

func _on_delete_canceled() -> void:
	input_enabled = true
