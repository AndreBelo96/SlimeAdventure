extends Node2D
class_name BaseTorch

@onready var light: PointLight2D = $PointLight2D

# Parametri configurabili
@export var energy_min: float = 0.9
@export var energy_max: float = 1.3
@export var scale_min: float = 0.9
@export var scale_max: float = 1.1
@export var flicker_time_min: float = 0.1
@export var flicker_time_max: float = 0.5

func _ready() -> void:
	_start_flicker()

func _start_flicker() -> void:
	_flicker()

func _flicker() -> void:
	var tween := create_tween()

	var new_energy := randf_range(energy_min, energy_max)
	tween.tween_property(light, "energy", new_energy, randf_range(flicker_time_min, flicker_time_max)) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	var new_scale := randf_range(scale_min, scale_max)
	tween.tween_property(light, "scale", Vector2.ONE * new_scale, randf_range(flicker_time_min, flicker_time_max)) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween.connect("finished", Callable(self, "_flicker"))
