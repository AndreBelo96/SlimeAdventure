extends "res://Scripts/Tiles/TileBase.gd"

func _ready():
	super._ready()
	set_region_from_coords(GameManager.WALL_TILE_POSITION, GameManager.get_tileset_row_for_level())
	sprite.texture = atlas_texture
	peso = 999

func can_enter() -> bool:
	
	return GameManager.has_pickaxe

func on_player_enter():
	#TODO animazione rottura se ho il piccone
	#TODO rumore
	#queue_free() -> se lo aggiungi devi cambaire e mettere quello normale altrimenti cade
	pass
