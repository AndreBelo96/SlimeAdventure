extends Node

# Proprietà per la modalità schermo e la risoluzione
var is_fullscreen: bool = false
var resolution: Vector2i = Vector2i(1280, 720)

func apply_display_settings(settings: Node):
	apply_fullscreen(settings.fullscreen)
	apply_resolution(settings.resolution)

func apply_fullscreen(checked_fullscreen: bool):
	is_fullscreen = checked_fullscreen
	if is_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		get_window().size = resolution

func apply_resolution(resolution_passed: int):
	if not is_fullscreen:
		match resolution_passed:
			0: resolution = Vector2(1920, 1080)
			1: resolution = Vector2(1280, 720)
			2: resolution = Vector2(400, 240)
			3: resolution = Vector2(320, 180)
		
		get_window().size = resolution
