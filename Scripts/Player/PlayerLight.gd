class_name PlayerLight
extends Resource

var light: PointLight2D

func setup(new_light: PointLight2D) -> void:
	light = new_light

func set_enabled(enabled: bool) -> void:
	if light:
		light.visible = enabled

func enable() -> void:
	set_enabled(true)

func disable() -> void:
	set_enabled(false)
