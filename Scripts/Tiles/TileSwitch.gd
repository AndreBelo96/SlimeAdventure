extends "res://Scripts/Tiles/TileBase.gd"

var key := "A"
var activated := false
var action := "deactivate"
@onready var shader_material = $AnimatedTile.material

func _ready():
	super._ready()
	shader_material = shader_material.duplicate()
	$AnimatedTile.material = shader_material
	add_to_group("switches")

func on_player_enter():
	if not activated:
		activated = true
		if PlayerRef.player:
			PlayerRef.player.lock_input()
		$AnimatedTile.play("PRESSED")
		SoundManager.play_sfx("res://Assets/Audio/Sound/SwitchClick.wav")
		await $AnimatedTile.animation_finished
		await get_tree().create_timer(0.2).timeout
		if PlayerRef.player:
			PlayerRef.player.unlock_input()
		emit_signal("tile_triggered", self, "switch", {"key": key, "action": action})
		deactivate()

func reset_switch():
	if activated:
		activated = false
		$AnimatedTile.play("UNPRESSED")
		SoundManager.play_sfx("res://Assets/Audio/Sound/ReverseSwitchClick.wav")
		emit_signal("tile_triggered", self, "switch", {"key": key, "action": "deactivate"})
		activate()

func deactivate():
	shader_material.set_shader_parameter("darkness", 0.5)
	shader_material.set_shader_parameter("desaturate", 1.0)

func activate():
	shader_material.set_shader_parameter("darkness", 0.0)
	shader_material.set_shader_parameter("desaturate", 0.0)
