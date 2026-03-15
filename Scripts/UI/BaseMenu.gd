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
enum MenuState { MAIN_MENU, SAVE_MENU, LOCATION_SELECT }
var current_state : MenuState = MenuState.MAIN_MENU

# --- Bottoni e selettori separati ---
var buttons_main : Array[Button] = []
var buttons_save : Array[Button] = []
var buttons_location : Array[Button] = []

# Array di array di selettori (ogni gruppo contiene 1 o 2 Node2D)
var selectors_main : Array = []
var selectors_save : Array = []
var selectors_location : Array = []

var current_selection := 0
var buttons: Array = []
var selectors: Array = []
var base_positions := {}
var input_enabled := true

## --- Costanti per i suoni (overrideabile se serve) ---
const SFX_MOVE = "res://Assets/Audio/TutorialBtnClick.wav"
const SFX_CONFIRM = "res://Assets/Audio/TutorialBtnClick.wav"

# --------------------------
# ------- LIFECYCLE --------
# --------------------------
func _ready() -> void:
	setup_languages()
	setup_main_buttons()
	setup_location_buttons()
	setup_save_buttons()
	setup_mouse()
	setup_main_selectors()
	setup_location_selectors()
	setup_save_selectors()
	
	current_state = GameManager.menu_state
	update_active_menu()
	set_current_selection(0)
	
	var main_container = $MenuContainer
	var save_container = $SaveSelectContainer
	var location_container = $LocationContainer

	if current_state == MenuState.MAIN_MENU:
		main_container.visible = true
		save_container.visible = false
		location_container.visible = false
	elif current_state == MenuState.SAVE_MENU:
		main_container.visible = false
		save_container.visible = true
		location_container.visible = false
	elif current_state == MenuState.LOCATION_SELECT:
		main_container.visible = false
		save_container.visible = false
		location_container.visible = true

# --------------------------
# --- INPUT MANAGEMENT ---
# --------------------------
func _unhandled_input(event):
	if not visible or not input_enabled:
		return

	if event.is_action_released("ui_accept"):
		handle_selection(current_selection)
	else:
		handle_navigation(event)

# --------------------------
# --- LINGUE / UI SETUP ---
# --------------------------
func setup_languages():
	GameLogger.warn("setup_languages() non implementato — deve essere definito nella sottoclasse")

# --------------------------
# --- BUTTONS / MOUSE -----
# --------------------------
func setup_main_buttons():
	GameLogger.warn("setup_buttons() non implementato — deve essere definito nella sottoclasse")

func setup_location_buttons():
	GameLogger.warn("setup_buttons() non implementato — deve essere definito nella sottoclasse")

func setup_save_buttons():
	GameLogger.warn("setup_buttons() non implementato — deve essere definito nella sottoclasse")

func setup_mouse():
	_connect_mouse_for(buttons_main)
	_connect_mouse_for(buttons_location)
	_connect_mouse_for(buttons_save)

func _connect_mouse_for(button_array: Array):
	for i in range(button_array.size()):
		var btn = button_array[i]
		btn.mouse_entered.connect(_on_label_mouse_entered.bind(i))
		btn.pressed.connect(_on_button_pressed.bind(i))

func _on_label_mouse_entered(index):
	SoundManager.play_sfx("res://Assets/Audio/TutorialBtnClick.wav")
	current_selection = index
	set_current_selection(current_selection)

func _on_button_pressed(index):
	handle_selection(index)

func store_base_positions() -> void:
	for selector in selectors:
		base_positions[selector] = selector.position

# --------------------------
# --- SELECTORS ------------
# --------------------------
func setup_main_selectors():
	push_warning("setup_selectors() non implementato — deve essere definito nella sottoclasse")

func setup_location_selectors():
	push_warning("setup_selectors() non implementato — deve essere definito nella sottoclasse")

func setup_save_selectors():
	push_warning("setup_selectors() non implementato — deve essere definito nella sottoclasse")

func set_current_selection(_current_selection: int):
	update_active_menu()
	
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
	#for sel in group:
		#print(sel.name, ": base = ", base_positions.get(sel, sel.position))
	
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

# --------------------------
# --- INPUT LOGIC ----------
# --------------------------
func handle_navigation(_event):
	GameLogger.warn("handle_navigation() non implementato — deve essere definito nella sottoclasse")

func handle_selection(_index: int):
	GameLogger.warn("handle_selection() non implementato — deve essere definito nella sottoclasse")

# --------------------------
# --- UTILITY --------------
# --------------------------
func get_current_buttons() -> Array:
	if current_state == MenuState.MAIN_MENU:
		return buttons_main
	elif current_state == MenuState.SAVE_MENU:
		return buttons_save
	else:
		return buttons_location

func get_current_selectors() -> Array:
	if current_state == MenuState.MAIN_MENU:
		return selectors_main
	elif current_state == MenuState.SAVE_MENU:
		return selectors_save
	else:
		return selectors_location

func update_active_menu():
# Aggiorna array attivi in base allo stato
	if current_state == MenuState.MAIN_MENU:
		buttons = buttons_main
		selectors = selectors_main
	elif current_state == MenuState.SAVE_MENU:
		buttons = buttons_save
		selectors = selectors_save
	elif current_state == MenuState.LOCATION_SELECT:
		buttons = buttons_location
		selectors = selectors_location

	# Nascondi tutti i selectors dei menu
	for group in selectors_main + selectors_save + selectors_location:
		for sel in group:
			sel.visible = false

	# Mostra solo i selectors del menu attivo
	for group in selectors:
		for sel in group:
			sel.visible = true

func rebuild_base_positions():
	base_positions.clear()
	for group in selectors:
		for sel in group:
			call_deferred("_store_base_position", sel)

func _store_base_position(sel):
	base_positions[sel] = sel.position
