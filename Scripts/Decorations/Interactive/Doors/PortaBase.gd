extends Node2D

var direction: String = "N"
var is_open: bool = false

func _ready():
	print(get_path(), " -> Y:", global_position.y)
	add_to_group("porte")
	update_visual()

func setup(dir: String):
	direction = dir
	update_visual()

func open():
	if not is_open:
		is_open = true
		update_visual()

func update_visual():
	var sprite = $AnimatedSprite2D
	var state = "Open_" if is_open else "Closed_"
	sprite.play(state + direction)
