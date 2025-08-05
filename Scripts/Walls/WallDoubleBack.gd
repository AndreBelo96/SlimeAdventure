extends "res://Scripts/Walls/WallBackBase.gd"

func _ready():
	super._ready()
	set_region_from_coords(7,  GameManager.get_tileset_row_for_level())
	sprite.texture = atlas_texture
