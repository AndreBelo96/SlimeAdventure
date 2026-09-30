extends "res://Scripts/Tiles/TileSpikeBase.gd"

func _ready():
	super._ready()
	weight = 8
	is_active = true

func _atlas_id() -> String:
	return "spike"
