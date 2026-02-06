extends Node2D

@onready var sprite := $Sprite2D

func _ready():
	animate()

func animate():
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(sprite, "modulate:a", 0.7, 0.4).from(0.25)
	tween.tween_property(sprite, "modulate:a", 0.25, 0.4)
