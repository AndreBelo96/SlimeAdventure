extends "res://Scripts/Tiles/TileBase.gd"

#signal interruttore_premuto(chiave: String)

var chiave := "A"
var attivato := false

func _ready():
	super._ready()
	add_to_group("interruttori")
	set_region_from_coords(GameManager.SWITCH_TILE_POSITION, GameManager.get_tileset_row_for_level())
	sprite.texture = atlas_texture

func on_player_enter():
	if not attivato:
		attivato = true
		$AnimatedTile.play("PRESSED")
		debug_log("Interruttore premuto: " + chiave)
		emit_signal("tile_triggered", self, "switch", {"chiave": chiave})
		#emit_signal("interruttore_premuto", chiave)
