extends SelectableMenuPanel
class_name ProfileSaveSlotSelectionPanel

signal slot_chosen(index: int)
signal back_pressed

const SLOT_BTN_SCENE := preload("res://Scenes/UI/MainMenu/Profile/ProfileSaveSlotBtn.tscn")
const SLOT_COUNT := 4

@onready var grid: GridContainer = $PanelContainer/MarginContainer/VBoxContainer/CenterContainer/GridContainer
@onready var btn_theme: BtnTheme = $PanelContainer/MarginContainer/VBoxContainer/BtnTheme

var slot_cards: Array[ProfileSaveSlotBtn] = []

func setup_languages() -> void:
	$PanelContainer/MarginContainer/VBoxContainer/Label.text = tr("SAVE_SLOT_TITLE")
	btn_theme.set_text(tr("BACK_BTN"))

func setup_buttons() -> void:
	_create_slot_cards()
	buttons = []
	for card in slot_cards:
		buttons.append(card.button)
	buttons.append(btn_theme.button)

func setup_selectors() -> void:
	selectors = []
	for card in slot_cards:
		selectors.append([card.selector])
	selectors.append(btn_theme.get_selector_group())

func activate(start_index: int = 0) -> void:
	_refresh_slot_data()
	super.activate(start_index)

func handle_selection(index: int) -> void:
	SoundManager.play_sfx(SFX_CONFIRM)
	if index == slot_cards.size():
		back_pressed.emit()
		return
	slot_chosen.emit(index)

func handle_navigation(_event: InputEvent) -> void:
	var back_index := slot_cards.size()
	var new_selection := current_selection

	if current_selection < back_index:
		if Input.is_action_just_pressed("move_right") and current_selection < back_index - 1:
			new_selection += 1
		elif Input.is_action_just_pressed("move_left") and current_selection > 0:
			new_selection -= 1
		elif Input.is_action_just_pressed("move_down"):
			new_selection = back_index
	else:
		if Input.is_action_just_pressed("move_up"):
			new_selection = 0

	if new_selection != current_selection:
		SoundManager.play_sfx(SFX_MOVE)
		current_selection = new_selection
		set_current_selection(current_selection)

## ---- Interno ---- ##
func _create_slot_cards() -> void:
	for child in grid.get_children():
		child.queue_free()
	slot_cards.clear()
	for i in range(SLOT_COUNT):
		var card: ProfileSaveSlotBtn = SLOT_BTN_SCENE.instantiate()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.add_child(card)
		slot_cards.append(card)

func _refresh_slot_data() -> void:
	for i in range(slot_cards.size()):
		slot_cards[i].setup(i + 1, SaveManager.get_slot_preview(i + 1))
