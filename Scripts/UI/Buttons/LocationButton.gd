extends Button

const BUTTON_SIZE := Vector2(210, 70)

func setup(location_name: String, locked: bool, theme: Theme) -> void:
	text = location_name
	disabled = locked
	
	if theme != null:
		self.theme = theme
	else:
		add_theme_color_override("font_color", Color.WHITE)

	focus_mode = Control.FOCUS_NONE
	set_custom_minimum_size(BUTTON_SIZE)
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	size_flags_vertical = Control.SIZE_SHRINK_CENTER
	
