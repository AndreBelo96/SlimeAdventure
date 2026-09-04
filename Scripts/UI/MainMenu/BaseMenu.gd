extends Control
class_name BaseMenu
## Classe base per tutti i menu.
## Gestisce logica comune di selezione, colori, suoni e animazione dei selettori.
## Ogni sottoclasse deve implementare:
##   - setup_buttons()
##   - setup_selectors()
##   - handle_selection(index)
##   - handle_navigation(event)

# --------------------------
# --- VARIABILI COMUNI  ---
# --------------------------
enum MenuState { MAIN_MENU, SAVE_MENU, OPTION_MENU, SAVE_SLOT_ACTIONS, LOCATION_SELECT }

# --- Bottoni e selettori separati ---
var buttons_main : Array[Button] = []
var buttons_save : Array[Button] = []
var buttons_save_data : Array[Button] = []
var buttons_location : Array[Button] = []

# Array di array di selettori (ogni gruppo contiene 1 o 2 Node2D)
var selectors_main : Array = []
var selectors_save : Array = []
var selectors_save_data : Array = []
var selectors_location : Array = []

var current_selection := 0
var buttons: Array = []
var selectors: Array = []
var base_positions := {}
var input_enabled := true

## --- Costanti per i suoni (overrideabile se serve) ---
const SFX_MOVE = "res://Assets/Audio/Sound/TutorialBtnClick.wav"
const SFX_CONFIRM = "res://Assets/Audio/Sound/TutorialBtnClick.wav"

# --------------------------
# ------- LIFECYCLE --------
# --------------------------
func _ready() -> void:
	setup_languages()
	setup_buttons()
	setup_selectors()
	setup_mouse()

# --------------------------
# --- INPUT MANAGEMENT ---
# --------------------------
func _unhandled_input(event):
	if not visible or not input_enabled:
		return
	get_viewport().set_input_as_handled()
	if event.is_action_released("ui_accept"):
		handle_selection(current_selection)
	else:
		handle_navigation(event)

func setup_languages():
	GameLogger.warn("setup_languages() non implementato — deve essere definito nella sottoclasse")

func setup_buttons():
	GameLogger.warn("setup_buttons() non implementato — deve essere definito nella sottoclasse")

func setup_selectors():
	GameLogger.warn("setup_selectors() non implementato — deve essere definito nella sottoclasse")

func setup_mouse():
	buttons = buttons_main
	selectors = selectors_main
	for i in range(buttons.size()):
		var btn = buttons[i]
		btn.mouse_entered.connect(_on_label_mouse_entered.bind(i))
		btn.pressed.connect(_on_button_pressed.bind(i))

func _on_label_mouse_entered(index):
	SoundManager.play_sfx(SFX_MOVE)
	current_selection = index
	set_current_selection(current_selection)

func _on_button_pressed(index):
	handle_selection(index)

func set_current_selection(_current_selection: int):
	for i in range(buttons.size()):
		var btn = buttons[i]
		if i == _current_selection:
			btn.add_theme_color_override("font_color", Color.WHITE)
			btn.modulate = Color(1, 1, 1)
		else:
			btn.add_theme_color_override("font_color", Color.BLACK)
			btn.modulate = Color8(176, 176, 176)

	for group in selectors:
		for sel in group:
			sel.text = ""

	if _current_selection >= selectors.size():
		return

	var group = selectors[_current_selection]
	group[0].text = ">"
	if group.size() > 1:
		group[1].text = "<"

	await get_tree().process_frame
	_start_tween(group)

func _start_tween(group: Array):
	var vertical = group.size() == 1
	for sel in group:
		if sel.has_meta("tween"):
			sel.get_meta("tween").kill()
		var base = base_positions.get(sel, sel.position)
		if base == null:
			base = sel.position
			base_positions[sel] = base
		sel.position = base
		var offset = Vector2.ZERO
		if vertical:
			offset = Vector2(0, -5)
		else:
			offset = Vector2(-5, 0) if sel == group[0] else Vector2(5, 0)
		var tween = create_tween().set_loops()
		tween.tween_property(sel, "position", base + offset, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(sel, "position", base, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		sel.set_meta("tween", tween)

func handle_navigation(_event):
	GameLogger.warn("handle_navigation() non implementato — deve essere definito nella sottoclasse")

func handle_selection(_index: int):
	GameLogger.warn("handle_selection() non implementato — deve essere definito nella sottoclasse")
