extends BaseMenu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	setup_results()

func setup_results():
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

func setup_languages():
	pass

func setup_buttons():
	buttons = [
		$ColorRect/MarginContainer/VBoxContainer/HBoxContainer3/VBoxContainer/HBoxContainer3/Next,
		$ColorRect/MarginContainer/VBoxContainer/HBoxContainer3/VBoxContainer/HBoxContainer2/BackLevelSelection,
		$ColorRect/MarginContainer/VBoxContainer/HBoxContainer3/VBoxContainer/HBoxContainer/BackMainMenu
	]

func setup_selectors():
	selectors = [
		[$ColorRect/MarginContainer/VBoxContainer/HBoxContainer3/VBoxContainer/HBoxContainer3/SelectorL, $ColorRect/MarginContainer/VBoxContainer/HBoxContainer3/VBoxContainer/HBoxContainer3/SelectorR],
		[$ColorRect/MarginContainer/VBoxContainer/HBoxContainer3/VBoxContainer/HBoxContainer2/SelectorL, $ColorRect/MarginContainer/VBoxContainer/HBoxContainer3/VBoxContainer/HBoxContainer2/SelectorR],
		[$ColorRect/MarginContainer/VBoxContainer/HBoxContainer3/VBoxContainer/HBoxContainer/SelectorL, $ColorRect/MarginContainer/VBoxContainer/HBoxContainer3/VBoxContainer/HBoxContainer/SelectorR],
	]
	await get_tree().process_frame
	
	for group in selectors:
		for sel in group:
			base_positions[sel] = sel.position

func handle_navigation(_event):
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

func handle_selection(_index):
	SoundManager.play_sfx("res://Assets/Audio/TutorialBtnClick.wav")
	if (_index == 0):
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		GameManager.next_level()
	elif (_index == 1):
		get_tree().change_scene_to_file("res://Scenes/UI/LocationSelection.tscn")
	elif (_index == 2):
		get_tree().change_scene_to_file("res://Scenes/UI/MainMenu.tscn")
