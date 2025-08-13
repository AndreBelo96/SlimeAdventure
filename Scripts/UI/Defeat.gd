extends Node2D

func _input(event):
	if event is InputEventKey and event.pressed:
		GameManager.restart_level()
