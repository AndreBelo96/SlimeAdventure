extends Node2D
class_name WallBackBase

@onready var sprite := $Tile

const TILESET := preload("res://Assets/Sprites/Walls/set_wall.png")
var atlas_texture := AtlasTexture.new()

func _ready():
	sprite.region_enabled = false
	atlas_texture.atlas = TILESET
	sprite.modulate.a = 0.4

func can_enter() -> bool:
	return false

func set_region_from_coords(tile_x: int, tile_y: int, tile_width := 66, tile_height := 83):
	atlas_texture.region = Rect2(
		Vector2(tile_x * tile_width, tile_y * tile_height),
		Vector2(tile_width, tile_height)
	)
