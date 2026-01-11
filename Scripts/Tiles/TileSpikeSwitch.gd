extends "res://Scripts/Tiles/TileBase.gd"

var chiave := "A"
var attivo := true
var azione := "disattiva"

func _ready():
	print("TileSpikes ready:", name, "script:", get_script())
	super._ready()
	add_to_group("spine")

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
	print("TILE: CHANGE STATE DIS")
	attivo = false
	$AnimatedTile.play("OFF")
	peso = 1

func attiva():
	print("TILE: CHANGE STATE ACT")
	attivo = true
	$AnimatedTile.play("ON")
	peso = 6
	emit_signal("state_changed", self, "ON")

func on_player_enter():
	if attivo:
		emit_signal("tile_triggered", self, "death", {"death_type": GameManager.Death.SPIKES, "chiave": chiave})

func on_enemy_enter(_enemy: EnemyBase):
	print("TILE: ENEMY ENTER")
	if attivo:
		print("TILE: ACTIVE")
		_enemy.receive_hit("damage")
		emit_signal("tile_triggered", self, "enemy_hit", {"enemy": _enemy})
