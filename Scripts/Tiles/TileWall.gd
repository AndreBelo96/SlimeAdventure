extends "res://Scripts/Tiles/TileBase.gd"

var is_broken := false

func _ready():
	super._ready()
	set_region_from_coords(LocationManager.WALL_TILE_POSITION, LocationManager.get_tileset_row_for_level())
	sprite.texture = atlas_texture
	weight = 999

func can_enter() -> bool:
	return LevelStateManager.has_pickaxe

func on_player_enter():
	if !is_broken:
		$AnimatedTile.play("EXPLOSION")
		SoundManager.play_sfx(AudioPresets.SMASH_STONE, 0.0, 0.08)
		weight = 1
		is_broken = true
