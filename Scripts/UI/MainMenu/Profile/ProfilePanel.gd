extends Control
class_name ProfilePanel

signal back_pressed

@onready var total_panel: ProfileTotalPanel = $MarginContainer/ProfileTotalPanel
@onready var location_panel: ProfileLocationPanel = $MarginContainer/ProfileLocationPanel

enum SubState {TOTAL, LOCATION }
var current_sub_state: SubState = SubState.TOTAL
var slot_selected := 0
var slot_data: Dictionary = {}

func _ready() -> void:
	total_panel.back_pressed.connect(_on_total_back)
	total_panel.location_chosen.connect(_on_location_chosen)
	location_panel.back_pressed.connect(_on_location_back)

func open_slot(slot: int) -> void:
	slot_selected = slot - 1
	slot_data = SaveManager.get_slot_preview(slot)

func activate(_start_index: int = 0) -> void:
	visible = true
	_switch_sub(SubState.TOTAL)

func deactivate() -> void:
	visible = false
	total_panel.deactivate()
	location_panel.deactivate()

func calibrate_positions() -> void:
	var total_was_visible = total_panel.visible
	total_panel.visible = true
	await get_tree().process_frame
	total_panel.calibrate_positions()
	total_panel.visible = total_was_visible

	var loc_was_visible = location_panel.visible
	location_panel.visible = true
	await get_tree().process_frame
	location_panel.calibrate_positions()
	location_panel.visible = loc_was_visible

## ---- Navigazione interna ---- ##
func _switch_sub(state: SubState, start_index: int = 0) -> void:
	current_sub_state = state
	total_panel.visible = (state == SubState.TOTAL)
	location_panel.visible = (state == SubState.LOCATION)

	total_panel.deactivate()
	location_panel.deactivate()

	match state:
		SubState.TOTAL:
			total_panel.show_data(slot_data)
			total_panel.activate(start_index)
		SubState.LOCATION:
			location_panel.activate(start_index)

func _on_total_back() -> void:
	back_pressed.emit()

func _on_location_chosen(location) -> void:
	location_panel.show_location(location, slot_data)
	_switch_sub(SubState.LOCATION)

func _on_location_back() -> void:
	_switch_sub(SubState.TOTAL)
