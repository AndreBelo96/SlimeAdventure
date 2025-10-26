extends Control

var current_selection = 0
var selectors := []
var base_positions = {}

func _ready():
	setup_languages()
	setup_selectors()
	setup_mouse()
	set_current_selection(0)

func _process(_delta):
	if Input.is_action_just_pressed("move_down") and current_selection < 4:
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
	$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer/HBoxContainer/Button/Start.text = tr("START_BTN")
	$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer2/HBoxContainer/Button/Profile.text = "Profile"
	$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer3/HBoxContainer/Button/Scoreboard.text = "Scoreboard"
	$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer4/HBoxContainer/Button/Option.text = tr("OPTIONS_BTN")
	$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer5/HBoxContainer/Button/Exit.text = tr("EXIT_BTN")

func setup_mouse():
	var buttons = [
		$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer/HBoxContainer/Button,
		$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer2/HBoxContainer/Button,
		$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer3/HBoxContainer/Button,
		$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer4/HBoxContainer/Button,
		$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer5/HBoxContainer/Button
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

func setup_selectors():
	selectors = [
		[$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer/HBoxContainer/SelectorL, $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer/HBoxContainer/SelectorR],
		[$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer2/HBoxContainer/SelectorL, $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer2/HBoxContainer/SelectorR],
		[$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer3/HBoxContainer/SelectorL, $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer3/HBoxContainer/SelectorR],
		[$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer4/HBoxContainer/SelectorL, $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer4/HBoxContainer/SelectorR],
		[$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer5/HBoxContainer/SelectorL, $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer5/HBoxContainer/SelectorR],
	]
	
	await get_tree().process_frame  # aspetta layout
	for pair in selectors:
		var left = pair[0]
		var right = pair[1]
		base_positions[left] = left.position
		base_positions[right] = right.position

func set_current_selection(_current_selection):
	for pair in selectors:
		pair[0].text = ""
		pair[1].text = ""
	
	var left = selectors[_current_selection][0]
	var right = selectors[_current_selection][1]
	
	left.text = ">"
	right.text = " <"
	
	await get_tree().process_frame
	_start_tween(left, right)

func _start_tween(left, right):
	
	if left.has_meta("tween"):
		left.get_meta("tween").kill()
	if right.has_meta("tween"):
		right.get_meta("tween").kill()
	
	var base_left = base_positions[left]
	var base_right = base_positions[right]

	var tween_left = create_tween().set_loops()
	tween_left.tween_property(left, "position:x", base_left.x - 5, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween_left.tween_property(left, "position:x", base_left.x, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	left.set_meta("tween", tween_left)

	var tween_right = create_tween().set_loops()
	tween_right.tween_property(right, "position:x", base_right.x + 5, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween_right.tween_property(right, "position:x", base_right.x, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	right.set_meta("tween", tween_right)

func handle_selection(_current_selection):
	SoundManager.play_sfx("res://Assets/Audio/TutorialBtnClick.wav")
	if (_current_selection == 0):
		get_tree().change_scene_to_file("res://Scenes/UI/LocationSelection.tscn")
	elif (_current_selection == 1):
		pass
	elif (_current_selection == 2):
		pass
	elif (_current_selection == 3):
		get_tree().change_scene_to_file("res://Scenes/UI/OptionMenu.tscn")
	elif (_current_selection == 4):
		get_tree().quit()
