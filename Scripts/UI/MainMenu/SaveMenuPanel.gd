extends Control
class_name SaveMenuPanel

signal back_pressed
signal play_pressed

@onready var slot_select: SlotSelectPanel = $SaveSelectContainer/VBoxContainer/HBoxContainer/SlotSelectPanel
@onready var slot_actions: SlotActionsPanel = $SaveSelectContainer/VBoxContainer/HBoxContainer/SlotActionsPanel

var slot_selected := 0

func _ready() -> void:
	slot_select.slot_chosen.connect(_on_slot_chosen)
	slot_select.back_pressed.connect(func(): back_pressed.emit())
	slot_actions.play_pressed.connect(func(): play_pressed.emit())
	slot_actions.back_pressed.connect(_on_actions_back)

func activate(start_index: int = 0) -> void:
	visible = true
	slot_actions.visible = false
	slot_actions.deactivate()
	slot_select.visible = true
	slot_select.activate(start_index)

func deactivate() -> void:
	visible = false
	slot_select.deactivate()
	slot_actions.deactivate()

func calibrate_positions() -> void:
	slot_select.visible = true
	await get_tree().process_frame
	slot_select.calibrate_positions()

	var was_visible = slot_actions.visible
	slot_actions.visible = true
	await get_tree().process_frame
	slot_actions.calibrate_positions()
	slot_actions.visible = was_visible

func _on_slot_chosen(index: int) -> void:
	slot_selected = index
	LevelStateManager.current_save_slot = index + 1
	SaveManager.current_slot = index + 1
	SaveManager.load_progress()
	LevelStateManager.reload_save_data()

	slot_select.input_enabled = false

	slot_actions.visible = true
	slot_actions.show_slot(slot_selected + 1)
	slot_actions.activate(0)

func _on_actions_back() -> void:
	slot_actions.deactivate()
	slot_select.activate(slot_selected)
