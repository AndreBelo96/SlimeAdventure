extends SelectableMenu
class_name SelectableMenuPanel

func activate(start_index: int = 0) -> void:
	visible = true
	input_enabled = true
	for group in selectors:
		for sel in group:
			sel.visible = true
	current_selection = start_index
	set_current_selection(current_selection)

func deactivate() -> void:
	visible = false
	input_enabled = false
	for group in selectors:
		for sel in group:
			sel.visible = false
