# Scripts/Tiles/TileBase.gd
extends Node2D
class_name TileBase

@onready var sprite := $Tile
var tile_pos: Vector2i = Vector2i.ZERO
var peso: int = 1

signal tile_triggered(tile: TileBase, action: String, data: Dictionary)
signal state_changed(tile: TileBase, new_state: String)

var is_active := false
const TILESET := preload("res://Assets/Sprites/Tiles/Tileset.png")
var atlas_texture := AtlasTexture.new()

func _ready():
	sprite.region_enabled = false
	atlas_texture.atlas = TILESET

func on_player_enter():
	emit_signal("tile_triggered", self, "none", {})

func on_enemy_enter(_enemy: EnemyBase):
	pass

func can_enter() -> bool:
	return true

func set_region_from_coords(tile_x: int, tile_y: int, tile_width := 64, tile_height := 48):
	var offset = 1;
	
	var block_w = tile_width + 2 * offset
	var block_h = tile_height + 2 * offset
	
	atlas_texture.region = Rect2(
		Vector2(tile_x * block_w + offset, tile_y * block_h + offset),
		Vector2(tile_width, tile_height)
	)
