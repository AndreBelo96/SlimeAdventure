extends SelectableMenuPanel
class_name ProfileLocationPanel

signal back_pressed

const LEVEL_INFO_SCENE := preload("res://Scenes/UI/MainMenu/Profile/ProfileLevelLocationInfo.tscn")

@onready var title_lbl: Label = $PanelContainer/MarginContainer/VBoxContainer/Label
@onready var recap_container: GridContainer = $PanelContainer/MarginContainer/VBoxContainer/LocationRecapContainer
@onready var btn_theme: BtnTheme = $PanelContainer/MarginContainer/VBoxContainer/BtnTheme

func setup_languages() -> void:
	btn_theme.set_text(tr("BACK_BTN"))

func setup_buttons() -> void:
	buttons = [btn_theme.button]

func setup_selectors() -> void:
	selectors = [btn_theme.get_selector_group()]

func handle_selection(_index: int) -> void:
	SoundManager.play_sfx(SFX_CONFIRM)
	back_pressed.emit()

func show_location(location, slot_data: Dictionary) -> void:
	title_lbl.text = tr(LocationManager.location_translation_keys[location])

	for child in recap_container.get_children():
		child.queue_free()

	var level_data: Dictionary = slot_data.get("levels", {})
	for level in LocationManager.get_level_range_for_location(location):
		var card: ProfileLevelLocationInfo = LEVEL_INFO_SCENE.instantiate()
		recap_container.add_child(card)
		card.setup(level, level_data.get(str(level), {}))
