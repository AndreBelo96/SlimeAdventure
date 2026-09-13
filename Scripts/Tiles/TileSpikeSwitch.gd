extends "res://Scripts/Tiles/TileSpikeBase.gd"

var key := "A"
var action := "deactivate"

@onready var animation = $AnimatedTile

func _ready():
	super._ready()
	is_active = true
	add_to_group("spikes")

func set_initial_state():
	match action:
		"activate":
			is_active = false
			set_initial_frame("ON")
		"deactivate":
			is_active = true
			set_initial_frame("OFF")

func set_initial_frame(anim_name: String):
	$AnimatedTile.animation = anim_name
	$AnimatedTile.stop()
	$AnimatedTile.frame = 0

func deactivate():
	is_active = false
	SoundManager.play_sfx(AudioPresets.DEACTIVATE_SPINE, -20)
	weight = 1
	_play_locked("OFF")

func activate():
	is_active = true
	SoundManager.play_sfx(AudioPresets.ACTIVATE_SPINE, -20)
	weight = 8
	emit_signal("state_changed", self, "ON")
	_play_locked("ON")

func _play_locked(anim_name: String) -> void:
	if PlayerRef.player:
		PlayerRef.player.lock_input()
	animation.play(anim_name)
	await animation.animation_finished
	if PlayerRef.player:
		PlayerRef.player.unlock_input()

func _get_death_data() -> Dictionary:
	return {"death_type": DeathType.Type.SPIKES, "key": key}

func _on_enemy_hit(_enemy: EnemyBase) -> void:
	emit_signal("tile_triggered", self, "enemy_hit", {"enemy": _enemy})
