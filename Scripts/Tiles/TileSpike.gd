extends "res://Scripts/Tiles/TileSpikeBase.gd"

func _ready():
	super._ready()
	set_region_from_coords(LocationManager.SPIKE_TILE_POSITION, LocationManager.get_tileset_row_for_level())
	sprite.texture = atlas_texture
	weight = 8
	is_active = true
