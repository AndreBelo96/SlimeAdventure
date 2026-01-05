extends "res://Scripts/Tiles/TileBase.gd"

var chiave := "A"
var attivato := false
var azione := "disattiva"

func _ready():
	super._ready()
	add_to_group("interruttori")
	#set_region_from_coords(GameManager.SWITCH_TILE_POSITION, GameManager.get_tileset_row_for_level())
	#sprite.texture = atlas_texture

func on_player_enter():
	if not attivato:
		attivato = true
		$AnimatedTile.play("PRESSED")
		emit_signal("tile_triggered", self, "switch", {"chiave": chiave, "azione": azione})

func reset_switch():
	if attivato:
		attivato = false
		$AnimatedTile.play("UNPRESSED")
		emit_signal("tile_triggered", self, "switch", {"chiave": chiave, "azione": "disattiva"})
