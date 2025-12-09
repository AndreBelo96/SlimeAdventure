extends Node2D

var min_breath_time := 1.0
var max_breath_time := 3.0
var _breath_timer := 0.0
var _waiting_time := 0.0
var _is_breathing := false
@onready var animation : AnimatedSprite2D = $Animation

func _ready():
	_reset_breath_timer()

func _process(delta: float) -> void:
	_breath_timer += delta
	if _breath_timer >= _waiting_time:
		breath()

func breath():
	_is_breathing = true
	
	animation.play("BREATH")
	await animation.animation_finished
	
	_is_breathing = false
	animation.play("IDLE")

	_reset_breath_timer()

func _reset_breath_timer():
	_breath_timer = 0.0
	_waiting_time = randf_range(min_breath_time, max_breath_time)
