extends "res://Scripts/Tiles/TileBase.gd"

var chiave := "A"
var attivato := false
var azione := "disattiva"
@onready var shader_material = $AnimatedTile.material

func _ready():
	super._ready()
	shader_material = shader_material.duplicate()
	$AnimatedTile.material = shader_material
	add_to_group("interruttori")

func on_player_enter():
	if not attivato:
		attivato = true
		$AnimatedTile.play("PRESSED")
		SoundManager.play_sfx("res://Assets/Audio/Sound/SwitchClick.wav")
		emit_signal("tile_triggered", self, "switch", {"chiave": chiave, "azione": azione})
		deactivate()

func reset_switch():
	if attivato:
		attivato = false
		$AnimatedTile.play("UNPRESSED")
		SoundManager.play_sfx("res://Assets/Audio/Sound/ReverseSwitchClick.wav")
		emit_signal("tile_triggered", self, "switch", {"chiave": chiave, "azione": "disattiva"})
		activate()

func deactivate():
	shader_material.set_shader_parameter("darkness", 0.5)
	shader_material.set_shader_parameter("desaturate", 1.0)

func activate():
	shader_material.set_shader_parameter("darkness", 0.0)
	shader_material.set_shader_parameter("desaturate", 0.0)
