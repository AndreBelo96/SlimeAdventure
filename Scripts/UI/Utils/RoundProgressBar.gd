extends Control

@onready var bar := $TextureProgressBar

func _ready():
	hide()

func activate(current: float, _max: float):
	bar.max_value = _max
	bar.value = clamp(current, 0, _max)
	show()

func deactivate():
	hide()
