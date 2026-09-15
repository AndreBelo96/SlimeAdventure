extends MarginContainer
class_name ProfileLevelLocationInfo

@onready var level_lbl: Label = $PanelContainer/MarginContainer/VBoxContainer/Label
@onready var deaths_lbl: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Label2
@onready var steps_lbl: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Label3

func setup(level: int, data: Dictionary) -> void:
	level_lbl.text = "Livello %d" % level
	if data.is_empty():
		deaths_lbl.text = "☠️: -"
		steps_lbl.text = "Passi: -"
		return
	deaths_lbl.text = "☠️: %d" % _sum_deaths(data.get("deaths", {}))
	steps_lbl.text = "Passi: %d" % data.get("steps", 0)

func _sum_deaths(deaths: Dictionary) -> int:
	var total := 0
	for v in deaths.values():
		total += v
	return total
