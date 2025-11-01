extends Control

var current_selection = 0
var selectors := []
var buttons := []
var base_positions = {}

func _ready():
	setup_languages()
	setup_selectors()
	setup_mouse()

func _process(_delta):
	if Input.is_action_just_pressed("move_down") and current_selection < 2:
		SoundManager.play_sfx("res://Assets/Audio/TutorialBtnClick.wav")
		current_selection += 1
		set_current_selection(current_selection)
	elif Input.is_action_just_pressed("move_up") and current_selection > 0:
		SoundManager.play_sfx("res://Assets/Audio/TutorialBtnClick.wav")
		current_selection -= 1
		set_current_selection(current_selection)
	elif Input.is_action_just_pressed("ui_accept"):
		handle_selection(current_selection)

func setup_languages():
	pass

# -- Manage Muose -- #
func setup_mouse():
	buttons = [
		$ColorRect/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/BackMainMenu,
		$ColorRect/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2/BackLevelSelection,
		$ColorRect/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer3/Restart
	]
	
	for i in range(buttons.size()):
		var btn = buttons[i]
		btn.connect("mouse_entered", Callable(self, "_on_label_mouse_entered").bind(i))
		btn.connect("pressed", Callable(self, "_on_button_pressed").bind(i))

func _on_label_mouse_entered(index):
	SoundManager.play_sfx("res://Assets/Audio/TutorialBtnClick.wav")
	current_selection = index
	set_current_selection(current_selection)

func _on_button_pressed(index):
	handle_selection(index)

# -- Selector Methods -- #
func setup_selectors():
	
	selectors = [
		[$ColorRect/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/SelectorL, $ColorRect/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/SelectorR],
		[$ColorRect/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2/SelectorL, $ColorRect/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2/SelectorR],
		[$ColorRect/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer3/SelectorL, $ColorRect/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer3/SelectorR],
	]
	await get_tree().process_frame
	
	for group in selectors:
		for sel in group:
			base_positions[sel] = sel.position
	
	set_current_selection(0)

func set_current_selection(_current_selection):
	for i in range(buttons.size()):
		var btn = buttons[i]
		if i == _current_selection:
			btn.add_theme_color_override("font_color", Color.WHITE)
		else:
			btn.add_theme_color_override("font_color", Color.BLACK)
	
	for group in selectors:
		for sel in group:
			sel.text = ""
	
	var group = selectors[_current_selection]
	group[0].text = ">"
	if group.size() > 1:
		group[1].text = "<"
	
	await get_tree().process_frame
	_start_tween(group)

func _start_tween(group):
	var vertical = group.size() == 1
	
	for sel in group:
		if sel.has_meta("tween"):
			sel.get_meta("tween").kill()
		
		var base = base_positions[sel]
		var offset
		
		if vertical:
			offset = Vector2(0, -5)
		else:
			offset = Vector2(-5, 0) if sel == group[0] else Vector2(5, 0)
		
		var tween = create_tween().set_loops()
		tween.tween_property(sel, "position", base + offset, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(sel, "position", base, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		sel.set_meta("tween", tween)

# -- Btn selection -- #
func handle_selection(_current_selection):
	SoundManager.play_sfx("res://Assets/Audio/TutorialBtnClick.wav")
	if (_current_selection == 0):
		get_tree().change_scene_to_file("res://Scenes/UI/MainMenu.tscn")
	elif (_current_selection == 1):
		get_tree().change_scene_to_file("res://Scenes/UI/LocationSelection.tscn")
	elif (_current_selection == 2):
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		GameManager.restart_level()
