extends MarginContainer
class_name ProfileSaveSlotCard

@onready var title_lbl: Label = $HBoxContainer/VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/Title
@onready var last_played_lbl: Label = $HBoxContainer/VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/Label2
@onready var level_reach_lbl: Label = $HBoxContainer/VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/Label3
@onready var playtime_lbl: Label = $HBoxContainer/VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/Label4
@onready var selector: Label = $HBoxContainer/Selector
@onready var button: Button = $HBoxContainer/VBoxContainer/PanelContainer/Button

var slot: int = 1

func _ready() -> void:
	button.flat = true
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	selector.set_meta("bob_horizontal", true)

func setup(slot_index: int, data: Dictionary) -> void:
	slot = slot_index
	if data.get("levels", {}).is_empty():
		_show_empty()
		return
	title_lbl.text = "Slot %d" % slot
	last_played_lbl.text = "Ultima data: %s" % _format_date(data.get("last_played", 0))
	level_reach_lbl.text = "Livello raggiunto: %d" % data.get("max_level_reach", 1)
	playtime_lbl.text = "Tempo di gioco: %s" % _format_time(data.get("total_time", 0.0))

func _show_empty() -> void:
	title_lbl.text = "Slot %d - Vuoto" % slot
	last_played_lbl.text = "Ultima data: -"
	level_reach_lbl.text = "Livello raggiunto: -"
	playtime_lbl.text = "Tempo di gioco: -"

func _format_time(seconds: float) -> String:
	var total := int(seconds)
	@warning_ignore("integer_division")
	var hours := int(total / 3600)
	@warning_ignore("integer_division")
	var minutes := (total % 3600) / 60
	var secs := total % 60
	return "%02d:%02d:%02d" % [hours, minutes, secs]

func _format_date(unix_time: int) -> String:
	if unix_time == 0:
		return "-"
	var d = Time.get_datetime_dict_from_unix_time(unix_time)
	return "%02d/%02d/%d" % [d.day, d.month, d.year]
