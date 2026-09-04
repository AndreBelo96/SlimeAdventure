extends Control
class_name SelectableMenuPanel

const SFX_MOVE = "res://Assets/Audio/Sound/TutorialBtnClick.wav"
const SFX_CONFIRM = "res://Assets/Audio/Sound/TutorialBtnClick.wav"

var buttons: Array[Button] = []
var selectors: Array = []
var current_selection := 0
var base_positions := {}
var input_enabled := false

func _ready() -> void:
	setup_languages()
	setup_buttons()
	setup_selectors()
	_connect_mouse()

func _unhandled_input(event: InputEvent) -> void:
	if not visible or not input_enabled:
		return
	if event.is_action_released("ui_accept"):
		handle_selection(current_selection)
	else:
		handle_navigation(event)

## ----- Da sovrascrivere nelle sottoclassi ----- ##
func setup_languages() -> void:
	pass

func setup_buttons() -> void:
	GameLogger.warn("setup_buttons() non implementato in %s" % name)

func setup_selectors() -> void:
	GameLogger.warn("setup_selectors() non implementato in %s" % name)

func handle_selection(_index: int) -> void:
	GameLogger.warn("handle_selection() non implementato in %s" % name)

## ----- Navigazione di default (verticale) ----- ##
func handle_navigation(_event: InputEvent) -> void:
	var delta := 0
	if Input.is_action_just_pressed("move_down"):
		delta = 1
	elif Input.is_action_just_pressed("move_up"):
		delta = -1
	if delta != 0:
		SoundManager.play_sfx(SFX_MOVE)
		change_selection(delta)

func change_selection(delta: int) -> void:
	current_selection += delta
	current_selection = clamp(current_selection, 0, buttons.size() - 1)
	set_current_selection(current_selection)

## ----- Lifecycle (chiamato da MenuRoot) ----- ##
func activate(start_index: int = 0) -> void:
	visible = true
	input_enabled = true
	call_deferred("rebuild_base_positions")
	for group in selectors:
		for sel in group:
			sel.visible = true
	current_selection = start_index
	set_current_selection(current_selection)

func deactivate() -> void:
	input_enabled = false
	for group in selectors:
		for sel in group:
			sel.visible = false

## ----- Mouse ----- ##
func _connect_mouse() -> void:
	for i in range(buttons.size()):
		var btn = buttons[i]
		btn.mouse_entered.connect(_on_button_mouse_entered.bind(i))
		btn.pressed.connect(_on_button_pressed.bind(i))

func _on_button_mouse_entered(index: int) -> void:
	SoundManager.play_sfx(SFX_MOVE)
	current_selection = index
	set_current_selection(current_selection)

func _on_button_pressed(index: int) -> void:
	handle_selection(index)

## ----- Selettori / tween ----- ##
func set_current_selection(_current_selection: int) -> void:
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

func _start_tween(group: Array) -> void:
	var vertical = group.size() == 1
	for sel in group:
		if sel.has_meta("tween"):
			sel.get_meta("tween").kill()

		var base = base_positions.get(sel, sel.position)
		sel.position = base

		var offset := Vector2.ZERO
		if vertical:
			offset = Vector2(0, -5)
		else:
			offset = Vector2(-5, 0) if sel == group[0] else Vector2(5, 0)

		var tween := create_tween().set_loops()
		tween.tween_property(sel, "position", base + offset, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(sel, "position", base, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		sel.set_meta("tween", tween)

func store_base_positions() -> void:
	for group in selectors:
		for sel in group:
			base_positions[sel] = sel.position

func rebuild_base_positions() -> void:
	base_positions.clear()
	for group in selectors:
		for sel in group:
			call_deferred("_store_base_position", sel)

func _store_base_position(sel: Node) -> void:
	base_positions[sel] = sel.position
