extends Node

# Proprietà per la modalità schermo e la risoluzione
var is_fullscreen: int = 0
var resolution: Vector2i = Vector2i(1280, 720)

func apply_display_settings(settings: Node):
	apply_fullscreen(settings.fullscreen)
	apply_resolution(settings.resolution)

func apply_fullscreen(checked_fullscreen: int):
	is_fullscreen = checked_fullscreen
	if is_fullscreen == 0:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		get_tree().root.content_scale_size = resolution
	elif is_fullscreen == 1:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		get_tree().root.content_scale_size = resolution
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		get_window().size = resolution

func apply_resolution(resolution_passed: int):
	match resolution_passed:
		0: resolution = Vector2i(2560, 1440)
		1: resolution = Vector2i(1920, 1080)
		2: resolution = Vector2i(1280, 720)
		3: resolution = Vector2i(640, 360)

	if is_fullscreen == 2: # finestra
		get_window().size = resolution
	
	get_tree().root.content_scale_size = resolution
