extends Node2D
class_name PortaBase

var direction: String = "N"
var is_open: bool = false

func _ready():
	add_to_group("doors")
	update_visual()

func setup(dir: String):
	direction = dir
	update_visual()

func open():
	if not is_open:
		is_open = true
		SoundManager.play_sfx("res://Assets/Audio/Sound/Doors/Door.wav")
		update_visual()

func update_visual():
	var sprite = $AnimatedSprite2D
	var state = "Open_" if is_open else "Closed_"
	sprite.play(state + direction)
