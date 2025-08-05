extends "res://Scripts/Tiles/TileBase.gd"

func _ready():
	super._ready()
	set_region_from_coords(GameManager.SPIKE_TILE_POSITION, GameManager.get_tileset_row_for_level())
	sprite.texture = atlas_texture

func on_player_enter():
	debug_log("Slime colpito dalle punte!")
	get_parent().get_parent().player._handle_death()
