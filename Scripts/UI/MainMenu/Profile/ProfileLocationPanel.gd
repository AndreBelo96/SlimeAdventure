extends SelectableMenuPanel
class_name ProfileLocationPanel

signal back_pressed

const LEVEL_CARD_SCENE := preload("res://Scenes/UI/MainMenu/Profile/ProfileLevelLocationCard.tscn")

@onready var title_lbl: Label = $PanelContainer/MarginContainer/VBoxContainer/Label
@onready var recap_container: GridContainer = $PanelContainer/MarginContainer/VBoxContainer/LocationRecapContainer
@onready var back_btn: BtnTheme = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Back
@onready var switch_btn: BtnTheme = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Change
@onready var boss_container: CenterContainer = $PanelContainer/MarginContainer/VBoxContainer/BossContainer

var level_cards: Array[ProfileLevelLocationCard] = []
var showing_record := true

func setup_languages() -> void:
	back_btn.set_text(tr("BACK_BTN"))
	switch_btn.set_text(tr("SWITCH_INFO_BTN"))

func setup_buttons() -> void:
	buttons = [switch_btn.button, back_btn.button]

func setup_selectors() -> void:
	selectors = [switch_btn.get_selector_group(), back_btn.get_selector_group()]

func handle_selection(index: int) -> void:
	SoundManager.play_sfx(SFX_CONFIRM)
	if index == 0:
		_toggle_info()
	else:
		back_pressed.emit()

func handle_navigation(_event: InputEvent) -> void:
	var new_selection := current_selection
	if Input.is_action_just_pressed("move_right") and current_selection < buttons.size() - 1:
		new_selection += 1
	elif Input.is_action_just_pressed("move_left") and current_selection > 0:
		new_selection -= 1

	if new_selection != current_selection:
		SoundManager.play_sfx(SFX_MOVE)
		current_selection = new_selection
		set_current_selection(current_selection)

func show_location(location, slot_data: Dictionary) -> void:
	title_lbl.text = tr(LocationManager.location_translation_keys[location])

	for child in recap_container.get_children():
		child.queue_free()
	for child in boss_container.get_children():
		child.queue_free()
	level_cards.clear()

	var level_data: Dictionary = slot_data.get("levels", {})
	var boss_level = LocationManager.location_boss_level.get(location, null)

	for level in LocationManager.get_level_range_for_location(location):
		if level == boss_level:
			continue
		_create_card(level, level_data.get(str(level), {}), recap_container)

	boss_container.visible = boss_level != null
	if boss_level != null:
		_create_card(boss_level, level_data.get(str(boss_level), {}), boss_container)
	
	showing_record = true

func _create_card(level: int, data: Dictionary, parent: Node) -> ProfileLevelLocationCard:
	var card: ProfileLevelLocationCard = LEVEL_CARD_SCENE.instantiate()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(card)
	card.setup(level, data)
	level_cards.append(card)
	return card

func _toggle_info() -> void:
	showing_record = !showing_record
	for card in level_cards:
		if showing_record:
			card.show_record()
		else:
			card.show_total()
