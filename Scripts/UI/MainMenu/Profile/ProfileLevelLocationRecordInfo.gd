extends MarginContainer
class_name ProfileLevelLocationRecordInfo

@onready var level_lbl: Label = $PanelContainer/MarginContainer/VBoxContainer/Label
@onready var steps_lbl: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Label3
@onready var time_lbl: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Label4


func setup(level: int, data: Dictionary) -> void:
	level_lbl.text = LocationManager.get_level_name(level)
	if data.is_empty():
		steps_lbl.text = "👣: -"
		time_lbl.text = "⌛: -"
		return
	steps_lbl.text = "👣: %d" % data.get("steps", 0)
	time_lbl.text = "⌛: %s" % FormatUtils.format_time_short(data.get("time", 0.0))
