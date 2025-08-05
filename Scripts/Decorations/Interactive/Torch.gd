extends Node2D

@onready var light = $PointLight2D

func _ready():
	print(name, " → Posizione: ", global_position, " | Y ordinamento: ", global_position.y)
	flicker()

func flicker():
	var tween = create_tween()
	
	var new_energy = randf_range(0.9, 1.3)
	tween.tween_property(light, "energy", new_energy, randf_range(0.1, 0.5)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	var new_scale = randf_range(0.9, 1.1)
	tween.tween_property(light, "scale", Vector2.ONE * new_scale, randf_range(0.1, 0.5)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.connect("finished", Callable(self, "flicker"))
