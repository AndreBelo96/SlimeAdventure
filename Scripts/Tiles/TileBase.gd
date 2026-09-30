# Scripts/Tiles/TileBase.gd
extends Node2D
class_name TileBase

const BLOCKED_WEIGHT := 999

signal tile_triggered(tile: TileBase, action: String, data: Dictionary)
@warning_ignore("UNUSED_SIGNAL")
signal state_changed(tile: TileBase, new_state: String)

@onready var visual: Node2D = $Visual
@onready var animated_tile: AnimatedSprite2D = $Visual/AnimatedTile

var weight: int = 1
var is_active := false
var _warning: TileWarning

func _ready():
	var id := _atlas_id()
	if id != "":
		animated_tile.sprite_frames = TileAtlas.get_frames(id, LocationManager.get_tileset_row_for_level())
		animated_tile.animation = _start_animation()
		animated_tile.frame = 0

## Chiave in TileAtlas.ANIMATIONS. Vuoto = tile logica invisibile (TileNormal).
func _atlas_id() -> String:
	return ""

func _start_animation() -> StringName:
	return &"default"

func on_player_enter():
	emit_signal("tile_triggered", self, "none", {})

func can_enter() -> bool:
	return true

## Muri, funghi, sassi: non ci si entra e non si sorvolano.
func is_blocking() -> bool:
	return weight >= BLOCKED_WEIGHT or not can_enter()

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
