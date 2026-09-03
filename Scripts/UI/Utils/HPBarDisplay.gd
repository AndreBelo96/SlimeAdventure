# Scripts/UI/Utils/HPBarDisplay.gd
class_name HPBarDisplay
extends Control

@export var segment_size := Vector2(40, 10)
@export var segment_gap := 3
@export var filled_color := Color(0.8, 0.15, 0.15)
@export var empty_color := Color(0.15, 0.15, 0.15)
@export var border_color := Color(0.05, 0.05, 0.05)
@export var border_width := 1
@export var corner_radius := 2

var max_hp := 1
var current_hp := 1

@onready var _container: HBoxContainer = $MarginContainer/HBoxContainer

func _ready() -> void:
	_container.add_theme_constant_override("separation", segment_gap)

func setup(_max_hp: int) -> void:
	max_hp = _max_hp
	current_hp = _max_hp
	_rebuild_segments()

func set_hp(value: int) -> void:
	current_hp = clamp(value, 0, max_hp)
	_update_colors()

func _rebuild_segments() -> void:
	for child in _container.get_children():
		_container.remove_child(child)
		child.queue_free()

	for i in range(max_hp):
		_container.add_child(_make_segment())

	_update_colors()

func _make_segment() -> Panel:
	var segment := Panel.new()
	segment.custom_minimum_size = segment_size

	var style := StyleBoxFlat.new()  # istanza unica per segmento, MAI condivisa
	style.set_corner_radius_all(corner_radius)
	style.border_width_left = border_width
	style.border_width_right = border_width
	style.border_width_top = border_width
	style.border_width_bottom = border_width
	style.border_color = border_color
	segment.add_theme_stylebox_override("panel", style)

	return segment

func _update_colors() -> void:
	var segments := _container.get_children()
	for i in range(segments.size()):
		var style: StyleBoxFlat = segments[i].get_theme_stylebox("panel")
		style.bg_color = filled_color if i < current_hp else empty_color
