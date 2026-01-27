extends Node2D
class_name BaseTorch

@onready var light: PointLight2D = $PointLight2D

var start_on := true

# Parametri configurabili
@export var energy_min: float = 0.9
@export var energy_max: float = 1.3
@export var scale_min: float = 0.9
@export var scale_max: float = 1.1
@export var flicker_time_min: float = 0.1
@export var flicker_time_max: float = 0.5

var is_on: bool = true
var flicker_tween: Tween

func _ready() -> void:
	add_to_group("torches")
	set_state(start_on)
	
	print("---- DEBUG YSORT TORCHES: ----")
	print("TORCHES  global Y:", global_position.y)
	print("TORCHES  z_index:", z_index)
	print("TORCHES  y_sort:", y_sort_enabled)
	print("TORCHES  parent:", get_parent().name)
	print("---------------------")

func _draw():
	print("DRAW ENEMY")
	draw_line(Vector2.ZERO, Vector2.DOWN * 10, Color.BLACK, 4)

func set_state(state: bool) -> void:
	if state:
		turn_on()
	else:
		turn_off()

func _start_flicker() -> void:
	if not is_on:
		return
	
	_flicker()

func _flicker() -> void:
	if not is_on:
		return
	
	flicker_tween = create_tween()

	var new_energy := randf_range(energy_min, energy_max)
	flicker_tween.tween_property(light, "energy", new_energy, randf_range(flicker_time_min, flicker_time_max)) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	var new_scale := randf_range(scale_min, scale_max)
	flicker_tween.tween_property(light, "scale", Vector2.ONE * new_scale, randf_range(flicker_time_min, flicker_time_max)) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	flicker_tween.connect("finished", Callable(self, "_flicker"))

func turn_on() -> void:
	if is_on:
		return
	
	is_on = true
	light.enabled = true
	_start_flicker()

func turn_off() -> void:
	if not is_on:
		return
	
	is_on = false
	
	if flicker_tween and flicker_tween.is_valid():
		flicker_tween.kill()
	
	light.energy = 0.0
	light.enabled = false
