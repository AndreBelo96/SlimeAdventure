extends RefCounted
class_name VisualEffects

const FLASH_COLOR := Color(2, 2, 2)
const NORMAL_COLOR := Color(1, 1, 1)

static func flash(node: CanvasItem, duration: float = 0.2, color: Color = FLASH_COLOR) -> void:
	node.modulate = color
	await node.get_tree().create_timer(duration).timeout
	node.modulate = NORMAL_COLOR
