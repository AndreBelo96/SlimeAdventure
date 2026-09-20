class_name UIFx
extends RefCounted

## Scossa a pendolo ogni tanto (piccone, trofei sbloccati).
static func flick(node: Control, pause: float = 2.0) -> Tween:
	var t := node.create_tween().set_loops(100000)
	# pivot ricalcolato a ogni ciclo: robusto anche se il layout non è ancora pronto
	t.tween_callback(func(): node.pivot_offset = node.size / 2.0)
	t.tween_interval(pause + randf_range(0.0, 1.5))  # sfalsa le icone tra loro
	t.tween_property(node, "rotation", -0.15, 0.08)
	t.tween_property(node, "rotation", 0.15, 0.16)
	t.tween_property(node, "rotation", 0.0, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	return t

## Respiro lento sull'asse Y (boss battuto).
static func breathe(node: Control) -> Tween:
	var t := node.create_tween().set_loops(100000)
	t.tween_callback(func(): node.pivot_offset = node.size / 2.0)
	t.tween_property(node, "scale", Vector2(1.0, 1.04), 1.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(node, "scale", Vector2.ONE, 1.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return t

## Pulsazione lenta dell'alpha (sagoma del boss non battuto, in agguato).
static func pulse_alpha(node: CanvasItem, low: float, high: float, duration: float = 1.6) -> Tween:
	var t := node.create_tween().set_loops(100000)
	t.tween_property(node, "modulate:a", low, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(node, "modulate:a", high, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return t
