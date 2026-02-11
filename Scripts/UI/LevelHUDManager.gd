# -- LevelHUDManager.gd -- #
extends Control

class_name LevelHUDManager

@onready var steps_label = $MarginContainer/StepsLabel
@onready var time_label = $MarginContainer/TimeLabel
@onready var tile_label = $MarginContainer/TileToActive
@onready var boss_life_bar = $MarginContainer/ProgressBar

func _ready():
	add_to_group("hud")

func update_steps(count: int):
	steps_label.text = "Passi: %d" % count

func update_time(time: float):
	time_label.text = "Tempo: %ds" % int(time)

func update_tile_label(activated: int, total: int):
	tile_label.text = "%d / %d" % [activated, total]

func update_progress_bar(dmg: int):
	boss_life_bar.value -= dmg

func setup_boss_level(boss_max_hp: int):
	tile_label.visible = false
	$MarginContainer/Sprite2D.visible = false
	boss_life_bar.visible = true
	boss_life_bar.max_value = boss_max_hp
	boss_life_bar.value = boss_max_hp

func setup_base_level():
	tile_label.visible = true
	$MarginContainer/Sprite2D.visible = true
	boss_life_bar.visible = false

func setup_progressbar(current: float, _max: float):
	$MarginContainer/RoundProgressBar.activate(current, _max)

func deactivate_progressbar():
	$MarginContainer/RoundProgressBar.deactivate()
