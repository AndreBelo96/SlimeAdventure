extends BaseTorch

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	sprite.modulate.a = 0.4
	super._ready()
