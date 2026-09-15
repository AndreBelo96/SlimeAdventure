extends Control
class_name ProfilePanel

signal back_pressed

@onready var slot_select: ProfileSaveSlotSelectionPanel = $MarginContainer/ProfileSaveSlotSelectionPanel
@onready var total_panel: ProfileTotalPanel = $MarginContainer/ProfileTotalPanel
@onready var location_panel: ProfileLocationPanel = $MarginContainer/ProfileLocationPanel

enum SubState { SLOT, TOTAL, LOCATION }
var current_sub_state: SubState = SubState.SLOT
var slot_selected := 0
var slot_data: Dictionary = {}

func _ready() -> void:
	slot_select.slot_chosen.connect(_on_slot_chosen)
	slot_select.back_pressed.connect(func(): back_pressed.emit())
	total_panel.back_pressed.connect(_on_total_back)
	total_panel.location_chosen.connect(_on_location_chosen)
	location_panel.back_pressed.connect(_on_location_back)

func activate(start_index: int = 0) -> void:
	visible = true
	_switch_sub(SubState.SLOT, start_index)

func deactivate() -> void:
	visible = false
	slot_select.deactivate()
	total_panel.deactivate()
	location_panel.deactivate()

func calibrate_positions() -> void:
	slot_select.visible = true
	await get_tree().process_frame
	slot_select.calibrate_positions()

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
	slot_select.visible = (state == SubState.SLOT)
	total_panel.visible = (state == SubState.TOTAL)
	location_panel.visible = (state == SubState.LOCATION)

	slot_select.deactivate()
	total_panel.deactivate()
	location_panel.deactivate()

	match state:
		SubState.SLOT:
			slot_select.activate(start_index)
		SubState.TOTAL:
			total_panel.show_data(slot_data)
			total_panel.activate(start_index)
		SubState.LOCATION:
			location_panel.activate(start_index)

func _on_slot_chosen(index: int) -> void:
	slot_data = SaveManager.get_slot_preview(index + 1)
	if slot_data.get("levels", {}).is_empty():
		return # slot vuoto, nessun profilo da mostrare
	slot_selected = index
	_switch_sub(SubState.TOTAL)

func _on_total_back() -> void:
	_switch_sub(SubState.SLOT, slot_selected)

func _on_location_chosen(location) -> void:
	location_panel.show_location(location, slot_data)
	_switch_sub(SubState.LOCATION)

func _on_location_back() -> void:
	_switch_sub(SubState.TOTAL)
