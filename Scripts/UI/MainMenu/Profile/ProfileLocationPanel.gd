extends SelectableMenuPanel
class_name ProfileLocationPanel

signal back_pressed

const LEVEL_CARD_SCENE := preload("res://Scenes/UI/MainMenu/Profile/ProfileLevelLocationCard.tscn")
const BOSS_CARD_SCENE := preload("res://Scenes/UI/MainMenu/Profile/ProfileBossCard.tscn")

@onready var title_lbl: Label = $PanelContainer/MarginContainer/VBoxContainer/Label
@onready var recap_container: GridContainer = $PanelContainer/MarginContainer/VBoxContainer/LocationRecapContainer
@onready var back_btn: BtnTheme = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Back
@onready var switch_btn: BtnTheme = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Change
@onready var boss_container: MarginContainer = $PanelContainer/MarginContainer/VBoxContainer/BossContainer

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
	title_lbl.text = tr(LocationManager.get_translation_key(location))
	var boss_level = LocationManager.get_boss_level(location)

	for child in recap_container.get_children():
		child.queue_free()
	for child in boss_container.get_children():
		child.queue_free()
	level_cards.clear()

	var level_data: Dictionary = slot_data.get("levels", {})

	for level in LocationManager.get_level_range_for_location(location):
		if level == boss_level:
			continue
		_create_card(level, level_data.get(str(level), {}), recap_container)

	boss_container.visible = boss_level != null
	if boss_level != null:
		var reward_id = LocationManager.get_boss_reward(location)
		var unlocks: Dictionary = slot_data.get("player", {}).get("unlocks", {})
		var boss_card: ProfileBossCard = BOSS_CARD_SCENE.instantiate()
		boss_container.add_child(boss_card)
		boss_card.setup(
			boss_level,
			level_data.get(str(boss_level), {}),
			reward_id,
			unlocks.get(reward_id, false) if reward_id != null else false,
			LocationManager.get_boss_portrait(location)
		)
		boss_card.play_intro(level_cards.size() * 0.04 + 0.1)
	
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
	for i in level_cards.size():
		var delay := ((i % recap_container.columns) + i / recap_container.columns) * 0.04
		if showing_record:
			level_cards[i].show_record(true, delay)
		else:
			level_cards[i].show_total(true, delay)
