extends Node2D


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/LocationSelection.tscn")


func _on_option_button_pressed() -> void:
	pass # Replace with function body.


func _on_exit_button_pressed() -> void:
	get_tree().quit()
