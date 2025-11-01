extends Control

var current_selection = 0
var selectors := []
var buttons := []
var base_positions = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var sprite = $ColorRect/MarginContainer/VBoxContainer/HBoxContainer/Control/Victory
	
	# Dati dell’ultima run, salvati in GameManager.end_level()
	var last = GameManager.last_attempt
	var completed_level: int = int(last["level"])
	var run_steps: int = int(last["steps"])
	var run_time: float = float(last["time"])
	var is_record: bool = bool(last.get("is_record", false))

	# Mostra i risultati della run appena conclusa
	$ColorRect/MarginContainer/VBoxContainer/HBoxContainer3/Points/Actual/ActualSteps.text = "Steps: %d" % [run_steps]
	$ColorRect/MarginContainer/VBoxContainer/HBoxContainer3/Points/Actual/ActualTime.text = "Time: %.2f" % [run_time]
	
	var best_steps := "-"
	var best_time := "-"
	
	var level_data := SaveManager.get_level_data(completed_level)
	if level_data.size() > 0:
		best_steps = str(level_data.get("steps", "-"))
		best_time = "%.2f" % float(level_data.get("time", 0.0))
	else:
		# prima volta: non c'erano dati, mostra i valori della run
		best_steps = str(run_steps)
		best_time = "%.2f" % run_time

	$ColorRect/MarginContainer/VBoxContainer/HBoxContainer3/Points/Best/BestSteps.text = "Steps: %s" % [best_steps]
	$ColorRect/MarginContainer/VBoxContainer/HBoxContainer3/Points/Best/BestTime.text = "Time: %s" % [best_time]
	
	if is_record:
		$ColorRect/MarginContainer/VBoxContainer/HBoxContainer/Record.text = "New record!!"
		sprite.texture = preload("res://Assets/Sprites/Player/Sunglasses.png")
	else:
		$ColorRect/MarginContainer/VBoxContainer/HBoxContainer/Record.text = "Nice!!"
		var atlas := AtlasTexture.new()
		atlas.atlas = preload("res://Assets/Sprites/Player/SlimeSet.png")
		atlas.region = Rect2(Vector2(0, 0), Vector2(32, 32))
		sprite.texture = atlas

	GameManager.isRecord = false
	
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
		$ColorRect/MarginContainer/VBoxContainer/HBoxContainer3/VBoxContainer/HBoxContainer/BackMainMenu,
		$ColorRect/MarginContainer/VBoxContainer/HBoxContainer3/VBoxContainer/HBoxContainer2/BackLevelSelection,
		$ColorRect/MarginContainer/VBoxContainer/HBoxContainer3/VBoxContainer/HBoxContainer3/Next
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
		[$ColorRect/MarginContainer/VBoxContainer/HBoxContainer3/VBoxContainer/HBoxContainer/SelectorL, $ColorRect/MarginContainer/VBoxContainer/HBoxContainer3/VBoxContainer/HBoxContainer/SelectorR],
		[$ColorRect/MarginContainer/VBoxContainer/HBoxContainer3/VBoxContainer/HBoxContainer2/SelectorL, $ColorRect/MarginContainer/VBoxContainer/HBoxContainer3/VBoxContainer/HBoxContainer2/SelectorR],
		[$ColorRect/MarginContainer/VBoxContainer/HBoxContainer3/VBoxContainer/HBoxContainer3/SelectorL, $ColorRect/MarginContainer/VBoxContainer/HBoxContainer3/VBoxContainer/HBoxContainer3/SelectorR],
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
		GameManager.next_level()
