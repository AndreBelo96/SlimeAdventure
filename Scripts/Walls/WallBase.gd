extends Node2D
class_name WallBase

@onready var sprite := $Tile

const TILESET := preload("res://Assets/Sprites/Walls/set_wall.png")
var atlas_texture := AtlasTexture.new()

func _ready():
	print(get_path(), " -> Y:", global_position.y)
	sprite.region_enabled = false
	atlas_texture.atlas = TILESET

func can_enter() -> bool:
	return false

func set_region_from_coords(tile_x: int, tile_y: int, tile_width := 66, tile_height := 83):
	atlas_texture.region = Rect2(
		Vector2(tile_x * tile_width, tile_y * tile_height),
		Vector2(tile_width, tile_height)
	)
