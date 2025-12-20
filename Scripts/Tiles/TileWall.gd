extends "res://Scripts/Tiles/TileBase.gd"

func _ready():
	super._ready()
	set_region_from_coords(GameManager.WALL_TILE_POSITION, GameManager.get_tileset_row_for_level())
	sprite.texture = atlas_texture

func can_enter() -> bool:
	#TODO animazione rottura se ho il piccone -> più queue free (quando farò the Big Reefactor sulle tile) - rimane un TODO intanto
	return GameManager.has_pickaxe
