# -- DialogInterface.gd -- #
extends Control
class_name DialogueInterface

signal dialogue_finished

@onready var text_label = $MarginContainer/PanelContainer/HBoxContainer/VBoxContainer/PanelText/TextLabel
@onready var name_label = $MarginContainer/PanelContainer/HBoxContainer/VBoxContainer/PanelName/NameLabel
@onready var portrait = $MarginContainer/PanelContainer/HBoxContainer/PanelPotrait/Portrait

@export var player: Node2D
@export var level_manager: Node2D

const DIALOG_PANEL_STYLE = preload("res://Theme/DialogueInterface/dialogue_panel.tres")

var location_colors := {
	GameManager.Location.TUTORIAL: {
		"border": Color("#dcdcdc"),
		"name": Color("#959595"),
		"text": Color("#dcdcdc")
	},
	GameManager.Location.DUNGEON: {
		"border": Color("#adb4cb"),
		"name": Color("#38477a"),
		"text": Color("#adb4cb")
	},
	GameManager.Location.FOREST: {
		"border": Color("#43a047"),
		"name": Color("#1b5e20"),
		"text": Color("#2e7d32")
	}
}

# Velocità tween
const TWEEN_TIME := 0.5

const max_visible_lines  := 3
var current_pages: Array = []
var current_page_index := 0

var current_dialogue = []
var current_index = 0
var is_typing = false
var key_pressed = false
var skip_typing = false

func show_dialogue(dialogue: Array):
	if get_tree().paused:
		return
	
	_apply_location_theme()
	
	if player:
		player.can_move = false
	
	if level_manager:
		level_manager.time_running = false
	
	for line in dialogue:
		if typeof(line) != TYPE_DICTIONARY or not line.has("text"):
			push_error("Dialogue line is invalid: " + str(line))
			return
	
	process_mode = Node.PROCESS_MODE_INHERIT
	current_dialogue = dialogue
	current_index = 0
	visible = true
	await _scale_in()
	_show_line()

func _show_line() -> void:
	if current_index >= current_dialogue.size():
		await _scale_out()
		visible = false
		
		if player:
			player.can_move = true
		
		if level_manager:
			level_manager.time_running = true
			
		emit_signal("dialogue_finished")
		return

	var line = current_dialogue[current_index]
	name_label.text = line.get("name", "")
	portrait.texture = line.get("portrait", null)
	_prepare_pages(line["text"])
	current_page_index = 0
	_type_text(current_pages[current_page_index])

func _prepare_pages(full_text: String) -> void:
	current_pages.clear()
	
	var remaining_words := full_text.split(" ", false)
	
	while remaining_words.size() > 0:
		
		var page_words := []
		
		for i in range(remaining_words.size()):
			
			page_words.append(remaining_words[i])
			var test_string := " ".join(page_words)
			text_label.text = test_string
			
			if text_label.get_line_count() > max_visible_lines:
				page_words.pop_back()
				break
		
		# sicurezza
		if page_words.size() == 0:
			page_words.append(remaining_words[0])
		
		var page_text := " ".join(page_words)
		
		current_pages.append(page_text)
		
		remaining_words = remaining_words.slice(page_words.size(), remaining_words.size() )

func _type_text(text: String):
	is_typing = true
	skip_typing = false
	text_label.text = ""
	var line = current_dialogue[current_index]
	
	var voice = line.get("voice", null)
	var voice_speed = line.get("voice_speed", VoiceManager.get_speed(line.get("name", "")))
	
	for i in range(text.length()):
		if skip_typing: 
			text_label.text = text
			break
		
		text_label.text += text[i]
		
		if voice and i % voice_speed == 0 and text[i] != " ":
			SoundManager.play_sfx(voice)
		
		await get_tree().create_timer(0.03, false).timeout
	is_typing = false

func _unhandled_input(event):
	if not visible:
		return
		
	if (event is InputEventKey or event is InputEventMouseButton) and not event.pressed:
		advance_dialogue()

func advance_dialogue():
	if is_typing:
		skip_typing = true
		return
	
	if current_page_index < current_pages.size() - 1:
		current_page_index += 1
		_type_text(current_pages[current_page_index])
	else:
		current_index += 1
		_show_line()


### --- Slimy Animations --- ###
func _scale_in():
	scale = Vector2(0.7, 1.3)
	modulate.a = 0.0

	var tween = create_tween()

	tween.set_parallel(true)

	tween.tween_property(self, "scale", Vector2(1.15, 0.85), 0.25)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)

	tween.tween_property(self, "modulate:a", 1.0, 0.2)

	await tween.finished

	var bounce = create_tween()
	bounce.tween_property(self, "scale", Vector2(0.95, 1.05), 0.12)
	bounce.tween_property(self, "scale", Vector2(1.02, 0.98), 0.12)
	bounce.tween_property(self, "scale", Vector2.ONE, 0.12)

func _scale_out():
	var tween = create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(self, "scale", Vector2(0.85, 0.85), 0.25)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_IN)
	tween.tween_property(self, "position", position + Vector2(0, 100), 0.25)
	tween.tween_property(self, "modulate:a", 0.0, 0.25)
	
	await tween.finished
	visible = false

### --- Location color --- ###
func _apply_location_theme():
	var location = GameManager.get_location_for_level(GameManager.current_level)
	var theme_data = location_colors.get(location, null)
	
	if theme_data == null:
		return
	
	var border_potrait = $MarginContainer/PanelContainer/HBoxContainer/PanelPotrait
	var border_name = $MarginContainer/PanelContainer/HBoxContainer/VBoxContainer/PanelName
	var border_text = $MarginContainer/PanelContainer/HBoxContainer/VBoxContainer/PanelText
	
	_apply_border(border_potrait, theme_data["border"])
	_apply_border(border_name, theme_data["border"])
	_apply_border(border_text, theme_data["border"])
	
	# Cambiare background nome
	text_label.add_theme_color_override("default_color", theme_data["text"])
	name_label.add_theme_color_override("font_color", theme_data["name"])

func _apply_border(panel: PanelContainer, color: Color):
	var style := DIALOG_PANEL_STYLE.duplicate() as StyleBoxFlat
	style.border_color = color
	panel.add_theme_stylebox_override("panel", style)
