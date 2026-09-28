# Scripts/Tiles/TileVineAnchor.gd
extends "res://Scripts/Tiles/TileBase.gd"
class_name TileVineAnchor
## Punto d'arrivo della liana. Calpestabile come una tile normale.

func _ready():
	super._ready()
	set_region_from_coords(LocationManager.VINE_ANCHOR_TILE_POSITION, LocationManager.get_tileset_row_for_level())
	sprite.texture = atlas_texture
	sprite.modulate = Color(0.45, 1.0, 0.45)
