# Scripts/Levels/SwitchSpikeHandler.gd
extends Resource
class_name SwitchSpikeHandler

signal switch_action_done

var tile_layer: Node2D
var boss_hit_by_switch := false
var switch_waiting_reset := false
var last_switch_pressed = null

func setup(_tile_layer: Node2D) -> void:
	tile_layer = _tile_layer

func on_step_begin() -> void:
	if switch_waiting_reset:
		if not boss_hit_by_switch:
			_reset_switch_and_spikes()
		switch_waiting_reset = false
		boss_hit_by_switch = false

func handle_switch(chiave: String, azione: String, sender) -> void:
	if azione == "attiva":
		last_switch_pressed = sender
		boss_hit_by_switch = false
		switch_waiting_reset = true

	for child in tile_layer.get_children():
		if child.is_in_group("spine") and child.chiave == chiave:
			match azione:
				"attiva":   child.attiva()
				"disattiva": child.disattiva()

	emit_signal("switch_action_done")

func notify_boss_hit() -> void:
	boss_hit_by_switch = true

func disable_all_spikes() -> void:
	for child in tile_layer.get_children():
		if child.is_in_group("spine"):
			child.disattiva()

func disable_spikes_with_key(key: String) -> void:
	for child in tile_layer.get_children():
		if child.is_in_group("spine") and child.chiave == key:
			child.disattiva()

func _reset_switch_and_spikes() -> void:
	if last_switch_pressed and last_switch_pressed.is_in_group("interruttori"):
		last_switch_pressed.reset_switch()
	last_switch_pressed = null
