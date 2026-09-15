extends SelectableMenuPanel
class_name ProfileTotalPanel

signal back_pressed
signal location_chosen(location)

@onready var general_info_container: CenterContainer = $HBoxContainer/ProfileContainer/MarginContainer/VBoxContainer/VBoxContainer/GeneralInfoContainer
@onready var location_name_container: VBoxContainer = $HBoxContainer/LocationContainer/MarginContainer/VBoxContainer/LocationNameContainer
@onready var btn_theme: BtnTheme = $HBoxContainer/ProfileContainer/MarginContainer/VBoxContainer/BtnTheme

var location_buttons: Array[Button] = []
var location_selectors: Array[Label] = []
var slot_data: Dictionary = {}

func setup_languages() -> void:
	btn_theme.set_text(tr("BACK_BTN"))

func setup_buttons() -> void:
	_create_location_buttons()
	buttons = location_buttons.duplicate()
	buttons.append(btn_theme.button)

func setup_selectors() -> void:
	selectors = []
	for sel in location_selectors:
		selectors.append([sel])
	selectors.append(btn_theme.get_selector_group())

func show_data(data: Dictionary) -> void:
	slot_data = data
	_populate_general_info()
	_update_location_buttons()

func handle_selection(index: int) -> void:
	SoundManager.play_sfx(SFX_CONFIRM)
	if index == location_buttons.size():
		back_pressed.emit()
		return
	var location_name = LocationManager.Location.keys()[index]
	if LocationManager.is_location_locked(location_name):
		return
	location_chosen.emit(LocationManager.Location.values()[index])

## ---- Interno ---- ##
func _create_location_buttons() -> void:
	for child in location_name_container.get_children():
		child.queue_free()
	location_buttons.clear()
	location_selectors.clear()

	for location_name in LocationManager.Location.keys():
		var row := HBoxContainer.new()
		var selector := Label.new()
		selector.custom_minimum_size = Vector2(20, 0)
		var button := Button.new()
		button.text = tr(LocationManager.location_translation_keys[LocationManager.Location[location_name]])
		button.flat = true
		button.focus_mode = Control.FOCUS_NONE
		row.add_child(selector)
		row.add_child(button)
		location_name_container.add_child(row)
		location_buttons.append(button)
		location_selectors.append(selector)

func _update_location_buttons() -> void:
	var locations = LocationManager.Location.keys()
	for i in range(location_buttons.size()):
		location_buttons[i].disabled = LocationManager.is_location_locked(locations[i])

func _populate_general_info() -> void:
	for child in general_info_container.get_children():
		child.queue_free()

	var completed: int = slot_data.get("levels", {}).size()
	var total_levels := LocationManager.get_number_of_levels()
	var deaths_total := _sum_deaths(slot_data.get("death_counts", {}))
	var best_time := _best_absolute_time(slot_data)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	_add_info_line(vbox, "Livelli completati: %d/%d" % [completed, total_levels])
	_add_info_line(vbox, "Passi totali: %d" % slot_data.get("total_steps", 0))
	_add_info_line(vbox, "Tempo totale: %s" % _format_time(slot_data.get("total_time", 0.0)))
	_add_info_line(vbox, "Tentativi totali: %d" % slot_data.get("total_attempts", 0))
	_add_info_line(vbox, "Morti totali: %d" % deaths_total)
	if best_time < INF:
		_add_info_line(vbox, "Miglior tempo assoluto: %s" % _format_time(best_time))

	general_info_container.add_child(vbox)

func _add_info_line(parent: VBoxContainer, text: String) -> void:
	var lbl := Label.new()
	lbl.text = text
	parent.add_child(lbl)

func _sum_deaths(deaths: Dictionary) -> int:
	var total := 0
	for v in deaths.values():
		total += v
	return total

func _best_absolute_time(data: Dictionary) -> float:
	var best := INF
	for level_key in data.get("levels", {}):
		var t = data["levels"][level_key].get("time", INF)
		if t < best:
			best = t
	return best

func _format_time(seconds: float) -> String:
	var total := int(seconds)
	@warning_ignore("integer_division")
	var hours := int(total / 3600)
	@warning_ignore("integer_division")
	var minutes := (total % 3600) / 60
	var secs := total % 60
	return "%02d:%02d:%02d" % [hours, minutes, secs]
