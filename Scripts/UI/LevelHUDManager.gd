# -- LevelHUDManager.gd -- #
extends Control

class_name LevelHUDManager

@onready var steps_label = $MarginContainer/StepsLabel
@onready var time_label = $MarginContainer/VBoxContainer/TimeLabel
@onready var tile_label = $MarginContainer/TileToActive
@onready var round_progressbar = $MarginContainer/VBoxContainer/RoundProgressBar
@onready var hp_display_bar = $HpBarDisplay

func _ready():
	add_to_group("hud")

func update_steps(count: int):
	steps_label.text = "Passi: %d" % count

func update_time(time: float):
	time_label.text = "Tempo: %ds" % int(time)

func update_tile_label(activated: int, total: int):
	tile_label.text = "%d / %d" % [activated, total]

func update_progress_bar(boss_hp: int):
	hp_display_bar.set_hp(boss_hp)

func setup_boss_level(boss_max_hp: int):
	tile_label.visible = false
	$MarginContainer/Sprite2D.visible = false
	hp_display_bar.setup(boss_max_hp)
	hp_display_bar.visible = false

func setup_base_level():
	tile_label.visible = true
	$MarginContainer/Sprite2D.visible = true
	hp_display_bar.visible = false

func show_boss_hp_bar():
	hp_display_bar.visible = true

func hide_boss_hp_bar():
	hp_display_bar.visible = false

func setup_progressbar(current: float, _max: float):
	round_progressbar.activate(current, _max)

func deactivate_progressbar():
	round_progressbar.deactivate()
