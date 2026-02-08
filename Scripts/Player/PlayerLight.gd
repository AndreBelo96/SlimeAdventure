class_name PlayerLight
extends Resource

var light: PointLight2D

var current_tween: Tween = null

func setup(new_light: PointLight2D) -> void:
	light = new_light

func set_enabled(enabled: bool) -> void:
	if light:
		light.visible = enabled
		light.energy = 1.0 if enabled else 0.0

func enable(fade_time: float = 1) -> void:	
	
	stop_tween()
	
	if not is_on():
		# luce SPENTA → fade-in
		light.visible = true
		light.energy = 0.0
		current_tween = light.create_tween()
		current_tween.tween_property(light, "energy", 1.0, fade_time)
		current_tween.connect("finished", func(): current_tween = null)
	else:
		# luce già accesa → on istantaneo
		light.visible = true
		light.energy = 1.0

func disable(fade_time: float = 1) -> void:
	if not light:
		return
		
	stop_tween()
	if fade_time <= 0:
		light.energy = 0.0
		light.visible = false
		return
	current_tween = light.create_tween()
	current_tween.tween_property(light, "energy", 0.0, fade_time)
	current_tween.tween_callback(func():
		light.visible = false
		current_tween = null
	)

func is_on() -> bool:
	return light and light.visible and light.energy > 0.0

func stop_tween() -> void:
	if current_tween:
		current_tween.kill()
		current_tween = null
