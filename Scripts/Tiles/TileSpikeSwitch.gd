extends "res://Scripts/Tiles/TileBase.gd"

var chiave := "A"
var attivo := true
var azione := "disattiva"

@onready var animation = $AnimatedTile

func _ready():
	super._ready()
	add_to_group("spikes")

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
	SoundManager.play_sfx(AudioPresets.DEACTIVATE_SPINE, -20)
	peso = 1
	_play_locked("OFF")

func attiva():
	attivo = true
	SoundManager.play_sfx(AudioPresets.ACTIVATE_SPINE, -20)
	peso = 8
	emit_signal("state_changed", self, "ON")
	_play_locked("ON")

func _play_locked(anim_name: String) -> void:
	if PlayerRef.player:
		PlayerRef.player.lock_input()
	animation.play(anim_name)
	await animation.animation_finished
	if PlayerRef.player:
		PlayerRef.player.unlock_input()

func on_player_enter():
	if attivo:
		emit_signal("tile_triggered", self, "death", {"death_type": DeathType.Type.SPIKES, "chiave": chiave})

func on_enemy_enter(_enemy: EnemyBase):
	if attivo:
		_enemy.receive_hit("damage")
		emit_signal("tile_triggered", self, "enemy_hit", {"enemy": _enemy})
