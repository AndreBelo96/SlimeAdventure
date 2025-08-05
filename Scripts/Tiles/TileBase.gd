# Scripts/Tiles/TileBase.gd
extends Node2D
class_name TileBase

@onready var sprite := $Tile

var is_active := false
const TILESET := preload("res://Assets/Sprites/Tiles/Tileset.png")
var atlas_texture := AtlasTexture.new()

func _ready():
	sprite.region_enabled = false
	atlas_texture.atlas = TILESET

func on_player_enter():
	# Comportamento base: non fa nulla
	pass

func can_enter() -> bool:
	return true

func set_region_from_coords(tile_x: int, tile_y: int, tile_width := 64, tile_height := 32):
	atlas_texture.region = Rect2(
		Vector2(tile_x * tile_width, tile_y * tile_height),
		Vector2(tile_width, tile_height)
	)

func debug_log(msg: String):
	print("[TileBase] ", msg)
