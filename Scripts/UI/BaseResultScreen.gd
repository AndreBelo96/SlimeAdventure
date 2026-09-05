extends BaseMenu
class_name BaseResultScreen

var root: Control
var title_wrapper: Control
var title: Label
var buttons_container: Control

func animate_title_slime(tween: Tween) -> void:
	title.modulate.a = 1.0
	tween.tween_property(title_wrapper, "scale", Vector2(1.25, 1.25), 0.35)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
	tween.tween_property(title_wrapper, "scale", Vector2(1, 1), 0.4)\
		.set_trans(Tween.TRANS_ELASTIC)\
		.set_ease(Tween.EASE_OUT)

func animate_buttons(tween: Tween) -> void:
	for child in buttons_container.get_children():
		tween.parallel().tween_property(child, "modulate:a", 1.0, 0.3)
		tween.parallel().tween_property(child, "position:y", child.position.y - 20, 0.4)\
			.set_trans(Tween.TRANS_BACK)\
			.set_ease(Tween.EASE_OUT)
		tween.tween_interval(0.1)

func animate_screen_exit() -> void:
	var tween = create_tween()
	# --- titolo slime squash ---
	tween.parallel().tween_property(title_wrapper, "scale", Vector2(1.2, 0.8), 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(title_wrapper, "scale", Vector2(0.0, 0.0), 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(title, "modulate:a", 0.0, 0.2)

	# --- hook per elementi extra della sottoclasse (es. Victory → results_container) ---
	_animate_screen_exit_extra(tween)

	# --- bottoni scendono e spariscono ---
	for child in buttons_container.get_children():
		tween.parallel().tween_property(child, "modulate:a", 0.0, 0.25)
		tween.parallel().tween_property(child, "position:y", child.position.y + 20, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)

	# --- shrink globale leggero ---
	tween.parallel().tween_property(root, "scale", Vector2(0.92, 0.92), 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(root, "modulate:a", 0.0, 0.3)

	await tween.finished

## Override nelle sottoclassi che hanno elementi extra da far sparire durante l'uscita.
func _animate_screen_exit_extra(_tween: Tween) -> void:
	pass
