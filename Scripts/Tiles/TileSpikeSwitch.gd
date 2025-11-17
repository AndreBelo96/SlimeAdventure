extends "res://Scripts/Tiles/TileBase.gd"

var chiave := "A"
var attivo := true
var azione := "disattiva"

func _ready():
	print("TileSpikes ready:", name, "script:", get_script())
	super._ready()
	add_to_group("spine")
	set_region_from_coords(GameManager.SPIKE_TILE_POSITION, GameManager.get_tileset_row_for_level())
	sprite.texture = atlas_texture

func set_initial_state():
	match azione:
		"attiva":
			attivo = false
			set_initial_frame("ON")
		"disattiva":
			attivo = true
			set_initial_frame("OFF")

func set_initial_frame(anim_name: String):
	$AnimatedTile.animation = anim_name
	$AnimatedTile.stop()
	$AnimatedTile.frame = 0

func disattiva():
	attivo = false
	$AnimatedTile.play("OFF")
	peso = 1

func attiva():
	attivo = true
	$AnimatedTile.play("ON")
	peso = 5
	emit_signal("state_changed", self, "ON")

func on_player_enter():
	if attivo:
		emit_signal("tile_triggered", self, "death", {"death_type": GameManager.Death.SPIKES, "chiave": chiave})

func on_enemy_enter(_enemy: EnemyBase):
	if attivo:
		_enemy.receive_hit("damage")
