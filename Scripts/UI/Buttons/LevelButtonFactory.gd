class_name LevelButtonFactory
extends Object

func create_level_button(label: String, is_disabled: bool, theme: Theme) -> VBoxContainer:
	var container = VBoxContainer.new()
	container.custom_minimum_size = Vector2(80, 60)
	container.set_anchors_preset(Control.PRESET_CENTER)

	# Il pulsante
	var button = Button.new()
	button.text = label
	button.disabled = is_disabled
	button.focus_mode = Control.FOCUS_NONE
	button.theme = theme
	button.set_size(Vector2(80, 20))
	button.set_custom_minimum_size(Vector2(80, 20))
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	container.add_child(button)

	# Il selector sotto al pulsante
	var selector_container = Control.new()
	
	var selector_label = Label.new()
	selector_label.name = "Selector"
	selector_label.text = ""
	selector_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	selector_label.rotation_degrees = -90
	selector_label.position = (Vector2(24, 20))
	selector_label.theme = preload("res://Theme/Title/normal_theme.tres")
	selector_container.add_child(selector_label)

	container.add_child(selector_container)

	return container
