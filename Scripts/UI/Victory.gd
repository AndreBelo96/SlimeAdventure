extends BaseMenu

@onready var root = $MarginContainer

@onready var title_wrapper = $MarginContainer/VBoxContainer/CenterContainer

@onready var title = $MarginContainer/VBoxContainer/CenterContainer/Title
@onready var next_level = $MarginContainer/VBoxContainer/HBoxContainer3/VBoxContainer/HBoxContainer3/Next/Next
@onready var retry = $MarginContainer/VBoxContainer/HBoxContainer3/VBoxContainer/HBoxContainer4/Retry/Retry
@onready var level_selection = $MarginContainer/VBoxContainer/HBoxContainer3/VBoxContainer/HBoxContainer2/BackLevelSelection/BackLevelSelection
@onready var back_menu = $MarginContainer/VBoxContainer/HBoxContainer3/VBoxContainer/HBoxContainer/BackMainMenu/BackMainMenu

@onready var actual = $MarginContainer/VBoxContainer/HBoxContainer3/Points/Actual/Actual
@onready var actual_steps = $MarginContainer/VBoxContainer/HBoxContainer3/Points/Actual/ActualSteps
@onready var actual_time = $MarginContainer/VBoxContainer/HBoxContainer3/Points/Actual/ActualTime

@onready var best = $MarginContainer/VBoxContainer/HBoxContainer3/Points/Best/Best
@onready var best_steps = $MarginContainer/VBoxContainer/HBoxContainer3/Points/Best/BestSteps
@onready var best_time = $MarginContainer/VBoxContainer/HBoxContainer3/Points/Best/BestTime

@onready var buttons_container  = $MarginContainer/VBoxContainer/HBoxContainer3/VBoxContainer
@onready var results_container = $MarginContainer/VBoxContainer/HBoxContainer3/Points
@onready var record = $MarginContainer/VBoxContainer/HBoxContainer/Record
@onready var record_container = $MarginContainer/VBoxContainer/HBoxContainer

var isRecordBool := false

var location_bg_colors := {
	GameManager.Location.TUTORIAL: {
		"name": Color("4a4a4aff")
	},
	GameManager.Location.DUNGEON: {
		"name": Color("#0f121a")
	},
	GameManager.Location.FOREST: {
		"name": Color("124616ff")
	}
}

func _ready():
	setup_languages()
	setup_buttons()
	setup_selectors()
	setup_mouse()
	set_current_selection(0)
	setup_results()
	_apply_location_theme()
	prepare_enter_animation()
	root.modulate.a = 0.0
	await get_tree().process_frame
	animate_screen_enter()

func setup_results():
	var sprite = $MarginContainer/VBoxContainer/HBoxContainer/Control/Victory

	# Dati dell’ultima run, salvati in GameManager.end_level()
	var last = GameManager.last_attempt
	var completed_level: int = int(last["level"])
	var run_steps: int = int(last["steps"])
	var run_time: float = float(last["time"])
	var is_record: bool = bool(last.get("is_record", false))

	isRecordBool = is_record

	# Mostra i risultati della run appena conclusa
	actual_steps.text = actual_steps.text + " %d" % [run_steps]
	actual_time.text = actual_time.text + " %.2f" % [run_time]

	var level_data := SaveManager.get_level_data(completed_level)
	if level_data.size() > 0:
		best_steps.text = best_steps.text + str(level_data.get("steps", "-"))
		best_time.text = best_time.text + "%.2f" % float(level_data.get("time", 0.0))
	else:
		best_steps.text = best_steps.text + str(run_steps)
		best_time.text = best_time.text + "%.2f" % run_time
	
	if is_record:
		record.text = tr("RECORD")
		sprite.texture = preload("res://Assets/Sprites/Player/Sunglasses.png")
	else:
		record.text = tr("NICE")
		var atlas := AtlasTexture.new()
		atlas.atlas = preload("res://Assets/Sprites/Player/SlimeSet.png")
		atlas.region = Rect2(Vector2(0, 0), Vector2(32, 32))
		sprite.texture = atlas

	GameManager.isRecord = false

func setup_languages():
	title.text = tr("VICTORY_LBL")
	next_level.text = tr("NEXT_LVL_BTN")
	retry.text = tr("RETRY_BTN")
	level_selection.text = tr("BACK_LVL_SELECTION")
	back_menu.text = tr("BACK_MAIN_MENU_BTN")
	
	actual.text = tr("CURRENT_LBL")
	actual_steps.text = tr("STEPS_LBL") + ":"
	actual_time.text = tr("TIME_LBL") + ":"
	
	best.text = tr("BEST_LBL")
	best_steps.text = tr("STEPS_LBL") + ": "
	best_time.text = tr("TIME_LBL") + ": "

func setup_buttons():
	buttons_main = [
		$MarginContainer/VBoxContainer/HBoxContainer3/VBoxContainer/HBoxContainer3/Next,
		$MarginContainer/VBoxContainer/HBoxContainer3/VBoxContainer/HBoxContainer4/Retry,
		$MarginContainer/VBoxContainer/HBoxContainer3/VBoxContainer/HBoxContainer2/BackLevelSelection,
		$MarginContainer/VBoxContainer/HBoxContainer3/VBoxContainer/HBoxContainer/BackMainMenu
	]

func setup_selectors():
	selectors_main = [
		[$MarginContainer/VBoxContainer/HBoxContainer3/VBoxContainer/HBoxContainer3/SelectorL, $MarginContainer/VBoxContainer/HBoxContainer3/VBoxContainer/HBoxContainer3/SelectorR],
		[$MarginContainer/VBoxContainer/HBoxContainer3/VBoxContainer/HBoxContainer4/SelectorL, $MarginContainer/VBoxContainer/HBoxContainer3/VBoxContainer/HBoxContainer4/SelectorR],
		[$MarginContainer/VBoxContainer/HBoxContainer3/VBoxContainer/HBoxContainer2/SelectorL, $MarginContainer/VBoxContainer/HBoxContainer3/VBoxContainer/HBoxContainer2/SelectorR],
		[$MarginContainer/VBoxContainer/HBoxContainer3/VBoxContainer/HBoxContainer/SelectorL, $MarginContainer/VBoxContainer/HBoxContainer3/VBoxContainer/HBoxContainer/SelectorR],
	]
	await get_tree().process_frame

	for group in selectors_main:
		for sel in group:
			base_positions[sel] = sel.position

func handle_navigation(_event):
	if Input.is_action_just_pressed("move_down") and current_selection < buttons.size()-1:
		SoundManager.play_sfx(SFX_MOVE)
		current_selection += 1
	elif Input.is_action_just_pressed("move_up") and current_selection > 0:
		SoundManager.play_sfx(SFX_MOVE)
		current_selection -= 1

	set_current_selection(current_selection)

func handle_selection(_index):
	SoundManager.play_sfx(SFX_CONFIRM)
	await animate_screen_exit()

	if (_index == 0):
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		GameManager.next_level()
	elif (_index == 1):
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		GameManager.restart_level(GameManager.current_level - 1)
	elif (_index == 2):
		GameManager.return_to_location_menu()
	elif (_index == 3):
		GameManager.return_to_menu()

### --- Animazioni entrata e uscita della schermata --- ###
func animate_screen_enter():
	var tween = create_tween()
	root.modulate.a = 1.0
	animate_title_slime(tween)
	tween.tween_interval(0.1)
	animate_results(tween)
	tween.tween_interval(0.15)
	animate_record(tween)
	tween.tween_interval(0.15)
	animate_buttons(tween)

func prepare_enter_animation():
	await get_tree().process_frame
	title_wrapper.pivot_offset = title_wrapper.size / 2.0
	title_wrapper.scale = Vector2(0.2, 0.2)
	title.modulate.a = 0.0
	for child in results_container.get_children():
		child.modulate.a = 0.0
	for child in buttons_container.get_children():
		child.modulate.a = 0.0

func animate_title_slime(tween):
	title.modulate.a = 1.0
	tween.tween_property(title_wrapper, "scale", Vector2(1.25, 1.25), 0.35)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
	tween.tween_property(title_wrapper, "scale", Vector2(1, 1), 0.4)\
		.set_trans(Tween.TRANS_ELASTIC)\
		.set_ease(Tween.EASE_OUT)

func animate_results(tween):
	for child in results_container.get_children():
		tween.tween_property(child, "modulate:a", 1.0, 0.35)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_OUT)
		tween.tween_interval(0.08)

func animate_buttons(tween):
	for child in buttons_container.get_children():
		tween.parallel().tween_property(child, "modulate:a", 1.0, 0.3)
		tween.parallel().tween_property(child, "position:y",
			child.position.y - 20, 0.4)\
			.set_trans(Tween.TRANS_BACK)\
			.set_ease(Tween.EASE_OUT)
		tween.tween_interval(0.1)

func animate_screen_exit() -> void:
	var tween = create_tween()
	# --- titolo slime squash ---
	tween.parallel().tween_property(title_wrapper, "scale", Vector2(1.2, 0.8), 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(title_wrapper, "scale", Vector2(0.0, 0.0), 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(title, "modulate:a", 0.0, 0.2)

	# --- risultati fade out ---
	for child in results_container.get_children():
		tween.parallel().tween_property(child, "modulate:a", 0.0, 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		tween.parallel().tween_property(child, "position:y", child.position.y + 10, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)

	# --- bottoni scendono e spariscono ---
	for child in buttons_container.get_children():
		tween.parallel().tween_property(child, "modulate:a", 0.0, 0.25)
		tween.parallel().tween_property(child, "position:y", child.position.y + 20, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)

	# --- shrink globale leggero ---
	tween.parallel().tween_property(root, "scale", Vector2(0.92, 0.92), 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(root, "modulate:a", 0.0, 0.3)

	await tween.finished

func animate_record(tween):
	record_container.modulate.a = 0.0
	record_container.scale = Vector2(0.5, 0.5)
	record_container.visible = true

	if isRecordBool:
		tween.parallel().tween_property(record_container, "modulate:a", 1.0, 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(record_container, "scale", Vector2(1.5, 1.5), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(record_container, "scale", Vector2(1.0,1.0), 0.25).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	else:
		tween.parallel().tween_property(record_container, "modulate:a", 1.0, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(record_container, "scale", Vector2(1.3, 1.3), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(record_container, "scale", Vector2(1,1), 0.25).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func _apply_location_theme():  #TODO se sono nell'ultimo livello, mi carica il colore del prossimo livello
	var location = GameManager.get_location_for_level(GameManager.current_level)
	var theme_data = location_bg_colors.get(location, null)

	if theme_data == null:
		return

	$ColorRect.color = theme_data["name"]
