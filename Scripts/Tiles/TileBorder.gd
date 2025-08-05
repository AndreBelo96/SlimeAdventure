extends "res://Scripts/Tiles/TileBase.gd"

func _ready():
	super._ready()
	set_region_from_coords(GameManager.BORDER_TILE_POSITION, GameManager.get_tileset_row_for_level())
	sprite.texture = atlas_texture
