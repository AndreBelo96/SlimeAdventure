extends Node2D

func _ready():
	$CanvasLayer/Menu/StartButton.text = tr("START_BTN")
	$CanvasLayer/Menu/HowToPlay.text = tr("HOW_TO_PLAY_BTN")
	$CanvasLayer/Menu/OptionButton.text = tr("OPTIONS_BTN")
	$CanvasLayer/Menu/ExitButton.text = tr("EXIT_BTN")

func _on_start_button_pressed() -> void:
	SoundManager.play_sfx("res://Assets/Audio/DefaultBtnClick.wav")
	get_tree().change_scene_to_file("res://Scenes/UI/LocationSelection.tscn")


func _on_option_button_pressed() -> void:
	SoundManager.play_sfx("res://Assets/Audio/DefaultBtnClick.wav")
	get_tree().change_scene_to_file("res://Scenes/UI/OptionMenu.tscn")


func _on_exit_button_pressed() -> void:
	SoundManager.play_sfx("res://Assets/Audio/DefaultBtnClick.wav")
	get_tree().quit()


func _on_how_to_play_pressed() -> void:
	SoundManager.play_sfx("res://Assets/Audio/DefaultBtnClick.wav")
	get_tree().change_scene_to_file("res://Scenes/UI/HowToPlay.tscn")
