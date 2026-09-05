extends BaseResultScreen

@onready var retry = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer3/Restart/Restart
@onready var level_selection = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2/BackLevelSelection/BackLevelSelection
@onready var back_menu = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/BackMainMenu/BackMainMenu

@onready var image_container = $MarginContainer/VBoxContainer/HBoxContainer/Control
@onready var image = $MarginContainer/VBoxContainer/HBoxContainer/Control/AnimatedSprite2D

func _ready():
	root = $MarginContainer
	title_wrapper = $MarginContainer/VBoxContainer/CenterContainer
	title = $MarginContainer/VBoxContainer/CenterContainer/Title
	buttons_container = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer
	
	setup_languages()
	setup_buttons()
	setup_selectors()
	setup_mouse()
	set_current_selection(0)
	_apply_location_theme()
	prepare_enter_animation()
	root.modulate.a = 0.0
	await get_tree().process_frame
	animate_screen_enter()

func setup_languages():
	title.text = tr("DEFEAT_LBL")
	retry.text = tr("RETRY_BTN")
	level_selection.text = tr("BACK_LVL_SELECTION")
	back_menu.text = tr("BACK_MAIN_MENU_BTN")

func setup_buttons():
	buttons_main = [
		$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer3/Restart,
		$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2/BackLevelSelection,
		$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/BackMainMenu,
	]

func setup_selectors():
	selectors_main = [
		[$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer3/SelectorL, $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer3/SelectorR],
		[$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2/SelectorL, $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2/SelectorR],
		[$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/SelectorL, $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/SelectorR],
	]
	
	await get_tree().process_frame
	for group in selectors_main:
		for sel in group:
			base_positions[sel] = sel.position

func handle_navigation(_event):
	if Input.is_action_just_pressed("move_down") and current_selection < 2:
		SoundManager.play_sfx(SFX_MOVE)
		current_selection += 1
	elif Input.is_action_just_pressed("move_up") and current_selection > 0:
		SoundManager.play_sfx(SFX_MOVE)
		current_selection -= 1
	
	set_current_selection(current_selection)

func handle_selection(_index):
	SoundManager.play_sfx(SFX_CONFIRM)
	if (_index == 0):
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		SceneNavigator.restart_level(LevelStateManager.current_level)
	elif (_index == 1):
		SoundManager.stop_music();
		SceneNavigator.return_to_location_menu()
	elif (_index == 2):
		SoundManager.stop_music();
		SceneNavigator.return_to_menu()

### --- Animazioni entrata e uscita della schermata --- ###

func animate_screen_enter():
	var tween = create_tween()
	root.modulate.a = 1.0
	animate_title_slime(tween)
	animate_image()
	tween.tween_interval(0.25)
	animate_buttons(tween)

func prepare_enter_animation():
	await get_tree().process_frame
	title_wrapper.pivot_offset = title_wrapper.size / 2.0
	title_wrapper.scale = Vector2(0.2, 0.2)
	title.modulate.a = 0.0
	for child in buttons_container.get_children():
		child.modulate.a = 0.0

func animate_image():
	image_container.modulate.a = 0.0
	image_container.scale = Vector2(0.5, 0.5)
	image_container.visible = true
	
	var tween_image = create_tween()
	tween_image.parallel().tween_property(image_container, "modulate:a", 1.0, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween_image.tween_property(image_container, "scale", Vector2(1.3, 1.3), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween_image.tween_property(image_container, "scale", Vector2(1,1), 0.25).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	
	await tween_image.finished
	
	image.play("Death")

func _apply_location_theme():
	$ColorRect.color = ThemeManager.get_result_bg_color_for_level(LevelStateManager.current_level)
