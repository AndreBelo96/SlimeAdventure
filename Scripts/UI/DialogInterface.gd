# -- DialogInterface.gd -- #
extends Control
class_name DialogueInterface

@onready var text_label = $Panel/TextLabel
@onready var name_label = $Panel/NameLabel
@onready var portrait = $Panel/Portrait

var current_dialogue = []
var current_index = 0
var is_typing = false
var key_pressed = false

func show_dialogue(dialogue: Array):
	for line in dialogue:
		if typeof(line) != TYPE_DICTIONARY or not line.has("text"):
			push_error("Dialogue line is invalid: " + str(line))
			return
	get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	current_dialogue = dialogue
	current_index = 0
	visible = true
	_show_line()

func _show_line():
	if current_index >= current_dialogue.size():
		visible = false
		get_tree().paused = false
		return

	var line = current_dialogue[current_index]
	name_label.text = line.get("name", "")
	portrait.texture = line.get("portrait", null)
	_type_text(line["text"])

func _type_text(text: String):
	is_typing = true
	text_label.text = ""
	var line = current_dialogue[current_index]
	
	var voice = line.get("voice", null)
	var voice_speed = line.get("voice_speed", VoiceManager.get_speed(line.get("name", "")))
	
	for i in text.length():
		text_label.text += text[i]
		
		if voice and i % voice_speed == 0 and text[i] != " ":
			SoundManager.play_sfx(voice)
		
		await get_tree().create_timer(0.03).timeout
	is_typing = false

func _unhandled_input(event):
	if not visible:
		return

	# Considera solo tasti o click rilasciati
	if (event is InputEventKey or event is InputEventMouseButton) and not event.pressed:
		if is_typing:
			return
		advance_dialogue()


func advance_dialogue():
	if is_typing:
		text_label.text = current_dialogue[current_index]["text"]
		is_typing = false
	else:
		current_index += 1
		_show_line()
