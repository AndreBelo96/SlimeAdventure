# Scripts/Tiles/TileBase.gd
extends Node2D
class_name TileBase

@onready var sprite := $Tile

signal tile_triggered(tile: TileBase, action: String, data: Dictionary)

var is_active := false
const TILESET := preload("res://Assets/Sprites/Tiles/Tileset.png")
var atlas_texture := AtlasTexture.new()

func _ready():
	sprite.region_enabled = false
	atlas_texture.atlas = TILESET
	debug_log("Tile pronta: " + str(self.name))

func on_player_enter():
	emit_signal("tile_triggered", self, "none", {})

func can_enter() -> bool:
	return true

func set_region_from_coords(tile_x: int, tile_y: int, tile_width := 64, tile_height := 32):
	atlas_texture.region = Rect2(
		Vector2(tile_x * tile_width, tile_y * tile_height),
		Vector2(tile_width, tile_height)
	)

func debug_log(msg: String):
	print("[TileBase] ", msg)

func _on_area_2d_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
