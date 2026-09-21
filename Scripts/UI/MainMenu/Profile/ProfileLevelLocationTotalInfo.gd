extends MarginContainer
class_name ProfileLevelLocationTotalInfo

@onready var level_lbl: Label = $PanelContainer/MarginContainer/VBoxContainer/Label
@onready var deaths_lbl: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Label2
@onready var steps_lbl: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Label3
@onready var time_lbl: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Label4


func setup(level: int, data: Dictionary) -> void:
	level_lbl.text = LocationManager.get_level_name(level)
	if data.is_empty():
		deaths_lbl.text = "☠️: -"
		steps_lbl.text = "👣: -"
		time_lbl.text = "⌛: -"
		return
	deaths_lbl.text = "☠️: %d" % FormatUtils.sum_deaths(data.get("deaths", {}))
	steps_lbl.text = "👣: %d" % data.get("total_steps", 0)
	time_lbl.text = "⌛: %s" % FormatUtils.format_time_short(data.get("total_time", 0.0))
