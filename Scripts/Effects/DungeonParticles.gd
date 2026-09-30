extends Node2D

func _ready():
	# aspetta che la scena sia pronta
	await get_tree().process_frame

	var camera = get_viewport().get_camera_2d()
	if camera:
		var screen_size = get_viewport_rect().size

		# posiziona le particelle in alto, centrato sulla camera
		global_position.x = camera.global_position.x - screen_size.x / 2
		global_position.y = camera.global_position.y - screen_size.y / 2
