class_name PlayerLight
extends Resource

var light: PointLight2D

func setup(new_light: PointLight2D) -> void:
	light = new_light

func set_enabled(enabled: bool) -> void:
	if light:
		light.visible = enabled
		light.energy = 1.0 if enabled else 0.0

func enable(fade_time: float = 1) -> void:
	if not light:
		return
	light.visible = true
	if fade_time <= 0:
		light.energy = 1.0
		return
	var tween = light.create_tween()
	tween.tween_property(light, "energy", 1.0, fade_time)

func disable(fade_time: float = 1) -> void:
	if not light:
		return
	if fade_time <= 0:
		light.energy = 0.0
		light.visible = false
		return
	var tween = light.create_tween()
	tween.tween_property(light, "energy", 0.0, fade_time)
	tween.tween_callback(func(): light.visible = false)
