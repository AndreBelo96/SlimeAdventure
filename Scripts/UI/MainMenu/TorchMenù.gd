extends Node2D

@export var min_energy := 0.7
@export var max_energy := 1.2
@export var speed := 8.0
@onready var light = $PointLight2D

var t := 0.0

func _process(delta):
	t += delta * speed
	light.energy = lerp(min_energy, max_energy, (sin(t) + sin(t*2.3) + sin(t*1.7)) / 3.0 * 0.5 + 0.5)
