extends SelectableMenuPanel
class_name ProfileTotalPanel

signal back_pressed
signal location_chosen(location)

const BTN_THEME_SCENE := preload("res://Scenes/UI/Utils/BtnTheme.tscn")

@onready var general_info_container: CenterContainer = $MarginContainer/HBoxContainer/ProfileContainer/MarginContainer/VBoxContainer/VBoxContainer/GeneralInfoContainer
@onready var location_name_container: VBoxContainer = $MarginContainer/HBoxContainer/LocationContainer/MarginContainer/VBoxContainer/LocationNameContainer
@onready var btn_theme: BtnTheme = $MarginContainer/HBoxContainer/LocationContainer/MarginContainer/VBoxContainer/BtnTheme
@onready var trophy_container: HBoxContainer = $MarginContainer/HBoxContainer/ProfileContainer/MarginContainer/VBoxContainer/VBoxContainer/TrophyContainer

var location_buttons: Array[Button] = []
var location_selectors: Array = []
var location_btn_themes: Array[BtnTheme] = []
var slot_data: Dictionary = {}

func setup_languages() -> void:
	btn_theme.set_text(tr("BACK_BTN"))

func setup_buttons() -> void:
	_create_location_buttons()
	buttons = location_buttons.duplicate()
	buttons.append(btn_theme.button)

func setup_selectors() -> void:
	selectors = location_selectors.duplicate()
	selectors.append(btn_theme.get_selector_group())

func show_data(data: Dictionary) -> void:
	slot_data = data
	_populate_general_info()
	_populate_trophies()
	_update_location_buttons()

func handle_selection(index: int) -> void:
	SoundManager.play_sfx(SFX_CONFIRM)
	if index == location_buttons.size():
		back_pressed.emit()
		return
	var location_name = LocationManager.Location.keys()[index]
	if _is_location_locked(location_name):
		return
	location_chosen.emit(LocationManager.Location.values()[index])

## ---- Interno ---- ##
func _create_location_buttons() -> void:
	for child in location_name_container.get_children():
		child.queue_free()
	location_buttons.clear()
	location_selectors.clear()
	location_btn_themes.clear()

	for location_name in LocationManager.Location.keys():
		var loc_btn: BtnTheme = BTN_THEME_SCENE.instantiate()
		location_name_container.add_child(loc_btn)
		loc_btn.set_text(tr(LocationManager.get_translation_key(LocationManager.Location[location_name])))
		location_buttons.append(loc_btn.button)
		location_selectors.append(loc_btn.get_selector_group())
		location_btn_themes.append(loc_btn)

func _update_location_buttons() -> void:
	var locations = LocationManager.Location.keys()
	for i in range(location_btn_themes.size()):
		location_btn_themes[i].set_locked(_is_location_locked(locations[i]))

func _populate_general_info() -> void:
	for child in general_info_container.get_children():
		child.queue_free()

	var completed: int = slot_data.get("levels", {}).size()
	var total_levels := LocationManager.get_number_of_levels()
	var completion_pct := 0
	if total_levels > 0:
		completion_pct = int(round(100.0 * completed / total_levels))

	var deaths: Dictionary = slot_data.get("death_counts", {})
	var deaths_total := _sum_deaths(deaths)
	var best_time := _best_absolute_time(slot_data)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)

	_add_section_title(vbox, "Progressi")
	_add_info_line(vbox, "Livelli completati: %d/%d (%d%%)" % [completed, total_levels, completion_pct])
	_add_info_line(vbox, "Vittorie totali: %d" % slot_data.get("total_victories", 0))

	_add_separator(vbox)
	_add_section_title(vbox, "Cumulativi")
	_add_info_line(vbox, "Passi totali: %d" % slot_data.get("total_steps", 0))
	_add_info_line(vbox, "Tempo totale: %s" % _format_time(slot_data.get("total_time", 0.0)))
	_add_info_line(vbox, "Tentativi totali: %d" % slot_data.get("total_attempts", 0))
	_add_info_line(vbox, "Morti totali: %d" % deaths_total)

	_add_separator(vbox)
	_add_section_title(vbox, "Record")
	if best_time < INF:
		_add_info_line(vbox, "Miglior tempo assoluto: %s" % _format_time(best_time))
	var worst_death := _most_frequent_death(deaths)
	if worst_death != "":
		_add_info_line(vbox, "Causa di morte preferita: %s" % worst_death)

	general_info_container.add_child(vbox)

func _populate_trophies() -> void:
	for child in trophy_container.get_children():
		child.queue_free()

	var unlocks: Dictionary = slot_data.get("player", {}).get("unlocks", {})

	for location_type in LocationManager.location_data:
		var reward_id = LocationManager.get_boss_reward(location_type)
		if reward_id == null:
			continue
		var unlocked: bool = unlocks.get(reward_id, false)
		var badge := _create_trophy_badge(reward_id, unlocked)
		trophy_container.add_child(badge)
		if unlocked:
			UIFx.flick(badge)

func _create_trophy_badge(reward_id: String, unlocked: bool) -> Control:
	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(32, 32)
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	var atlas := AtlasTexture.new()
	atlas.atlas = LocationManager.PICKUP_SPRITESHEET
	atlas.region = LocationManager.boss_reward_icons.get(reward_id, Rect2())
	icon.texture = atlas

	icon.modulate = Color.WHITE if unlocked else Color(0.25, 0.25, 0.25)
	return icon

func _add_separator(parent: VBoxContainer) -> void:
	parent.add_child(HSeparator.new())

func _most_frequent_death(deaths: Dictionary) -> String:
	var best_key := ""
	var best_count := 0
	for key in deaths:
		if deaths[key] > best_count:
			best_count = deaths[key]
			best_key = key
	if best_key == "":
		return ""
	return DeathType.type_names.get(int(best_key), "Sconosciuto")

func _add_info_line(parent: VBoxContainer, text: String) -> void:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 10)
	parent.add_child(lbl)

func _add_section_title(parent: VBoxContainer, text: String) -> void:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 15)
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

func _is_location_locked(location_name: String) -> bool:
	var location_type = LocationManager.Location[location_name]
	var levels := LocationManager.get_level_range_for_location(location_type)
	if levels.is_empty():
		return true
	return levels[0] > slot_data.get("max_level_reach", 1)
