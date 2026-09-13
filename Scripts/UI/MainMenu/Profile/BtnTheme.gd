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
