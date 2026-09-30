# Scripts/Tiles/TileVineAnchor.gd
extends "res://Scripts/Tiles/TileBase.gd"
class_name TileVineAnchor

var _pulse: Tween

func _ready():
	super._ready()
	animated_tile.modulate = Color(0.45, 1.0, 0.45)   # PLACEHOLDER

func _atlas_id() -> String:
	return "vine_anchor"

func set_reachable(on: bool) -> void:
	if _pulse:
		_pulse.kill()
	visual.modulate = Color.WHITE
	if on:
		_pulse = create_tween().set_loops()
		_pulse.tween_property(visual, "modulate", Color(1.8, 1.8, 1.8), 0.35)
		_pulse.tween_property(visual, "modulate", Color.WHITE, 0.35)
