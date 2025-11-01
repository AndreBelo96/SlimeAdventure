# Script LevelMenu
extends Control

@onready var level_container: GridContainer = $ColorRect/MarginContainer/VBoxContainer/CenterContainer2/LevelButtonContainer
@onready var location: Label = $ColorRect/MarginContainer/VBoxContainer/CenterContainer4/Location

var current_selection = 0
var selectors := []
var buttons := []
var base_positions = {}

var loader = preload("res://Scripts/UI/Buttons/LevelLoader.gd")
var factory = preload("res://Scripts/UI/Buttons/LevelButtonFactory.gd")

func _ready():
	loader = LevelLoader.new()
	factory = LevelButtonFactory.new()
	#setup_languages()
	
	location.text = GameManager.Location.keys()[GameManager.location_selected]
	load_level_buttons()

func load_level_buttons():
	for child in level_container.get_children():
		child.queue_free()
		
	buttons.clear()
	selectors.clear()
	base_positions.clear()

	var levels_info = loader.get_level_data_for_location(GameManager.location_selected)
	var levels_range = GameManager.get_level_range_for_location(GameManager.location_selected)

	for i in range(levels_info.size()):
		var info = levels_info[i]
		var relative_index = levels_range.find(loader.extract_level_number(info.path)) + 1
		var location_id = int(GameManager.location_selected)
		var display_number = "%d.%d" % [location_id, relative_index]

		var container = factory.create_level_button(display_number, info.disabled, info.theme)
		level_container.add_child(container)

		var button = container.get_child(0) as Button
		var selector_control = container.get_child(1)
		var selector_label = selector_control.get_node("Selector") as Label

		if button == null or selector_label == null:
			push_warning("Level button factory structure mismatch at index %d" % i)
			continue

		buttons.append(button)
		selectors.append([selector_label])
		base_positions[selector_label] = selector_label.position

	var back_button = $ColorRect/MarginContainer/VBoxContainer/CenterContainer3/HBoxContainer/Button
	var back_selector = [$ColorRect/MarginContainer/VBoxContainer/CenterContainer3/HBoxContainer/SelectorL, $ColorRect/MarginContainer/VBoxContainer/CenterContainer3/HBoxContainer/SelectorR]
	
	buttons.append(back_button)
	selectors.append(back_selector)
	
	await get_tree().process_frame
	for sel in back_selector:
		base_positions[sel] = sel.position
	
	if buttons.size() > 0:
		set_current_selection(0)
	
	setup_mouse()

func set_current_selection(_current_selection):
	if selectors.is_empty():
		return
	
	current_selection = clamp(_current_selection, 0, selectors.size() - 1)
	
	for i in range(buttons.size()):
		var btn = buttons[i]
		btn.add_theme_color_override("font_color", Color.WHITE if i == current_selection else Color.BLACK)
	
	for group in selectors:
		if group == null:
			continue
		for sel in group:
			if sel == null:
				continue
			sel.text = ""
	
	var group = selectors[_current_selection]
	group[0].text = ">"
	if group.size() > 1:
		group[1].text = "<"
	
	await get_tree().process_frame
	_start_tween(group)

func _start_tween(group):
	# Se è un singolo selector → verticale
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

func _unhandled_input(_delta):
	var max_index = buttons.size() - 1  # include anche il back button
		
	if Input.is_action_just_pressed("move_right") and current_selection < max_index:
		SoundManager.play_sfx("res://Assets/Audio/TutorialBtnClick.wav")
		current_selection += 1
		set_current_selection(current_selection)
	elif Input.is_action_just_pressed("move_left") and current_selection > 0:
		SoundManager.play_sfx("res://Assets/Audio/TutorialBtnClick.wav")
		current_selection -= 1
		set_current_selection(current_selection)
	elif Input.is_action_just_pressed("move_down") and current_selection < max_index:
		SoundManager.play_sfx("res://Assets/Audio/TutorialBtnClick.wav")
		current_selection = current_selection + 5 if current_selection + 5 <= max_index else max_index
		set_current_selection(current_selection)
	elif Input.is_action_just_pressed("move_up") and current_selection > 0:
		SoundManager.play_sfx("res://Assets/Audio/TutorialBtnClick.wav")
		current_selection = current_selection - 5 if current_selection - 5 >= 0 else 0
		set_current_selection(current_selection)
	elif Input.is_action_just_pressed("ui_accept"):
		handle_selection(current_selection)


# ------ MANAGE MOUSE ------ #
func setup_mouse():
	for i in range(buttons.size()):
		var btn = buttons[i]
		btn.connect("mouse_entered", Callable(self, "_on_label_mouse_entered").bind(i))
		btn.connect("pressed", Callable(self, "_on_button_pressed").bind(i))

func _on_button_pressed(index):
	handle_selection(index)

func _on_label_mouse_entered(index):
	SoundManager.play_sfx("res://Assets/Audio/TutorialBtnClick.wav")
	current_selection = index
	set_current_selection(current_selection)


func is_level_disabled() -> bool:
	return current_selection > GameManager.max_level_reach #Must trasform current_selection in actual number level

func handle_selection(_current_selection):
	
	if _current_selection == buttons.size() - 1:
		SoundManager.play_sfx("res://Assets/Audio/DefaultBtnClick.wav")
		get_tree().change_scene_to_file("res://Scenes/UI/LocationSelection.tscn")
		return
	
	if(is_level_disabled()):
		return
	
	# Altrimenti selezione livello
	var button = buttons[_current_selection]
	var info = loader.get_level_data_for_location(GameManager.location_selected)[_current_selection] ## Ma va?
	_on_level_button_pressed(info.path, info.sound)

func _on_level_button_pressed(path: String, sound: String):
	var level_num = loader.extract_level_number(path)
	GameManager.current_level = level_num

	var is_first_level_of_location = level_num == GameManager.get_level_range_for_location(GameManager.location_selected)[0]
	
	#SoundManager.play_sfx(sound);
	
	if is_first_level_of_location:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		var loader_scene = preload("res://Scenes/UI/TransitionScreen.tscn").instantiate()
		loader_scene.scene_to_load = path
		loader_scene.transition_text = GameManager.Location.keys()[GameManager.get_location_for_level(level_num)]
		loader_scene.location_id = int(GameManager.get_location_for_level(level_num))
		get_tree().root.add_child(loader_scene)
	else:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		get_tree().change_scene_to_file(path)

#func print_tree_paths(node: Node, prefix: String = ""):
	#for child in node.get_children():
		#var path = prefix + "/" + child.name
		#var type = child.get_class()
		#print(path, " (", type, ")")
		#print_tree_paths(child, path)
