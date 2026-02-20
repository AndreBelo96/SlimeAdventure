extends BaseMenu

@onready var root = $MarginContainer

@onready var title_wrapper = $MarginContainer/VBoxContainer/CenterContainer
@onready var title = $MarginContainer/VBoxContainer/CenterContainer/Title
@onready var buttons_container  = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer
@onready var image_container = $MarginContainer/VBoxContainer/HBoxContainer/Control
@onready var image = $MarginContainer/VBoxContainer/HBoxContainer/Control/AnimatedSprite2D

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
	_apply_location_theme()
	prepare_enter_animation()
	root.modulate.a = 0.0
	await get_tree().process_frame
	animate_screen_enter()

func setup_languages():
	pass

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
		GameManager.restart_level()
	elif (_index == 1):
		GameManager.return_to_location_menu()
	elif (_index == 2):
		GameManager.return_to_menu()

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

func animate_title_slime(tween):
	title.modulate.a = 1.0
	tween.tween_property(title_wrapper, "scale", Vector2(1.25, 1.25), 0.35)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
	tween.tween_property(title_wrapper, "scale", Vector2(1, 1), 0.4)\
		.set_trans(Tween.TRANS_ELASTIC)\
		.set_ease(Tween.EASE_OUT)

func animate_buttons(tween):
	for child in buttons_container.get_children():
		tween.parallel().tween_property(child, "modulate:a", 1.0, 0.3)
		tween.parallel().tween_property(child, "position:y", child.position.y - 20, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_interval(0.1)

func animate_screen_exit() -> void:
	var tween = create_tween()
	# --- titolo slime squash ---
	tween.parallel().tween_property(title_wrapper, "scale", Vector2(1.2, 0.8), 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(title_wrapper, "scale", Vector2(0.0, 0.0), 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(title, "modulate:a", 0.0, 0.2)

	# --- bottoni scendono e spariscono ---
	for child in buttons_container.get_children():
		tween.parallel().tween_property(child, "modulate:a", 0.0, 0.25)
		tween.parallel().tween_property(child, "position:y", child.position.y + 20, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)

	# --- shrink globale leggero ---
	tween.parallel().tween_property(root, "scale", Vector2(0.92, 0.92), 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(root, "modulate:a", 0.0, 0.3)

	await tween.finished

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
	var location = GameManager.get_location_for_level(GameManager.current_level)
	var theme_data = location_bg_colors.get(location, null)
	
	if theme_data == null:
		return
	
	$ColorRect.color = theme_data["name"]
