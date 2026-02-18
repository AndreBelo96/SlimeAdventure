# -- DialogInterface.gd -- #
extends Control
class_name DialogueInterface

signal dialogue_finished

@onready var text_label = $MarginContainer/PanelContainer/HBoxContainer/VBoxContainer/PanelContainer2/TextLabel
@onready var name_label = $MarginContainer/PanelContainer/HBoxContainer/VBoxContainer/PanelContainer/NameLabel
@onready var portrait = $MarginContainer/PanelContainer/HBoxContainer/PanelContainer/Portrait

@export var player: Node2D
@export var level_manager: Node2D

# Velocità tween
const TWEEN_TIME := 0.25
var tween: Tween = null

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
	_show_line()

func _show_line() -> void:
	if current_index >= current_dialogue.size():
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
	#_type_text(line["text"])
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
