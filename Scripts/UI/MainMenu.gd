extends Node2D


func _on_start_button_pressed() -> void:
	SoundManager.play_sfx("res://Assets/Audio/DefaultBtnClick.wav")
	get_tree().change_scene_to_file("res://Scenes/UI/LocationSelection.tscn")


func _on_option_button_pressed() -> void:
	SoundManager.play_sfx("res://Assets/Audio/DefaultBtnClick.wav")
	pass # Replace with function body.


func _on_exit_button_pressed() -> void:
	SoundManager.play_sfx("res://Assets/Audio/DefaultBtnClick.wav")
	get_tree().quit()


func _on_how_to_play_pressed() -> void:
	SoundManager.play_sfx("res://Assets/Audio/DefaultBtnClick.wav")
	get_tree().change_scene_to_file("res://Scenes/UI/HowToPlay.tscn")
