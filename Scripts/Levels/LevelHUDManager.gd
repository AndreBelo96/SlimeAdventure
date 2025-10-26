# -- LevelHUDManager.gd -- #
extends MarginContainer

class_name LevelHUDManager

@onready var steps_label = $StepsLabel
@onready var time_label = $TimeLabel
@onready var tile_label = $TileToActive

func update_steps(count: int):
	steps_label.text = "Passi: %d" % count

func update_time(time: float):
	time_label.text = "Tempo: %ds" % int(time)

func update_tile_label(activated: int, total: int):
	tile_label.text = "%d / %d" % [activated, total]
