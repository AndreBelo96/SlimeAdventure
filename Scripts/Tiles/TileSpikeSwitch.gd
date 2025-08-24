extends "res://Scripts/Tiles/TileBase.gd"

var chiave := "A"
var attivo := true

func _ready():
	super._ready()
	add_to_group("spine")
	set_region_from_coords(GameManager.SPIKE_TILE_POSITION, GameManager.get_tileset_row_for_level())
	sprite.texture = atlas_texture

func disattiva():
	attivo = false
	$AnimatedTile.play("OFF")

func on_player_enter():
	if attivo:
		debug_log("Spina disattivabile attiva → Slime colpito!")
		emit_signal("tile_triggered", self, "death", {"death_type": GameManager.DeathType.SPIKES, "chiave": chiave})
