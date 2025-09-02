extends Node2D

func _on_back_main_menu_pressed() -> void:
	SoundManager.play_sfx("res://Assets/Audio/DefaultBtnClick.wav")
	get_tree().change_scene_to_file("res://Scenes/UI/MainMenu.tscn")


func _on_back_level_selection_pressed() -> void:
	SoundManager.play_sfx("res://Assets/Audio/DefaultBtnClick.wav")
	get_tree().change_scene_to_file("res://Scenes/UI/LocationSelection.tscn")


func _on_restart_pressed() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	SoundManager.play_sfx("res://Assets/Audio/DefaultBtnClick.wav")
	GameManager.restart_level()
