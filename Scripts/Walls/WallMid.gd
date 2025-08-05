extends "res://Scripts/Walls/WallBase.gd"

func _ready():
	super._ready()
	set_region_from_coords(1,  GameManager.get_tileset_row_for_level())
	sprite.texture = atlas_texture
