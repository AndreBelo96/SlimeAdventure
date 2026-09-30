# Scripts/Tiles/TileBase.gd
extends Node2D
class_name TileBase

@onready var sprite := $Visual/Tile
@onready var animated_tile: AnimatedSprite2D = $Visual/AnimatedTile
@onready var visual: Node2D = $Visual

var weight: int = 1
var _warning: TileWarning

signal tile_triggered(tile: TileBase, action: String, data: Dictionary)
@warning_ignore("UNUSED_SIGNAL")
signal state_changed(tile: TileBase, new_state: String)

var is_active := false
const TILESET := preload("res://Assets/Sprites/Tiles/Logic_Tileset.png")
var atlas_texture := AtlasTexture.new()

func _ready():
	sprite.region_enabled = false
	atlas_texture.atlas = TILESET

func on_player_enter():
	emit_signal("tile_triggered", self, "none", {})

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

func set_warning(source: Object, warning_color: Color, priority := 0) -> void:
	if _warning == null:
		_warning = TileWarning.new()
		add_child(_warning)   # ultimo figlio: disegnato sopra Visual
		_warning.position = $Center.position
		_warning.setup(Vector2((get_parent() as TileMapLayer).tile_set.tile_size))
	_warning.set_source(source, warning_color, priority)

func clear_warning(source: Object) -> void:
	if _warning:
		_warning.clear_source(source)
