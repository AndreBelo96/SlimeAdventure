# Classe interna per disegnare il bordo
extends Control
class_name DebugBorder

@export var thickness: float = 2.0

func _draw():
	draw_rect(Rect2(Vector2.ZERO, size), Color(1,0,0,1), false, thickness)
