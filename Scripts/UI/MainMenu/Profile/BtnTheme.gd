extends CenterContainer
class_name BtnTheme

@onready var button: Button = $HBoxContainer/Button
@onready var label: Label = $HBoxContainer/Button/Label
@onready var selector_l: Label = $HBoxContainer/SelectorL
@onready var selector_r: Label = $HBoxContainer/SelectorR

func set_text(text: String) -> void:
	label.text = text

func get_selector_group() -> Array:
	return [selector_l, selector_r]

func set_locked(locked: bool) -> void:
	button.disabled = locked
	label.modulate = Color(1, 0.4, 0.4) if locked else Color.WHITE

func set_font_size(size: int) -> void:
	label.add_theme_font_size_override("font_size", size)
