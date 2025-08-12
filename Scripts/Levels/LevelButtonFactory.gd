class_name LevelButtonFactory
extends Object

func create_level_button(label: String, is_disabled: bool, theme: Theme) -> Button:
	var button = Button.new()
	button.text = label
	button.disabled = is_disabled
	button.focus_mode = Control.FOCUS_NONE
	button.theme = theme
	button.set_size(Vector2(100, 60))
	button.set_custom_minimum_size(Vector2(100, 60))
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return button
