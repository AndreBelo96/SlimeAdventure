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
		steps_lbl.text = "Passi: -"
		time_lbl.text = "⌛: -"
		return
	deaths_lbl.text = "☠️: %d" % _sum_deaths(data.get("deaths", {}))
	steps_lbl.text = "Passi: %d" % data.get("total_steps", 0)
	time_lbl.text = "⌛: %s" % _format_time(data.get("total_time", 0.0))

func _sum_deaths(deaths: Dictionary) -> int:
	var total := 0
	for v in deaths.values():
		total += v
	return total

func _format_time(seconds: float) -> String:
	var total := int(seconds)
	@warning_ignore("integer_division")
	var minutes := int(total / 60)
	var secs := total % 60
	return "%02d:%02d" % [minutes, secs]
