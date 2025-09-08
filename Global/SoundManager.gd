# Scripts/SoundManager.gd
extends Node

const AUDIO_SETTINGS_PATH := "user://audio_settings.save"

var music_volume: float = 1.0
var sfx_volume: float = 1.0
var master_volume: float = 1.0
var environment_volume: float = 1.0

var music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []

func _ready():
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)

	for i in range(8):
		var p = AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		sfx_players.append(p)


func play_music(path: String, loop := true):
	var stream = load(path)
	if not stream:
		push_warning("Music file not found: %s" % path)
		return

	if music_player.stream != stream:
		music_player.stop()
		music_player.stream = stream
		music_player.play()
		music_player.stream.loop = loop

func stop_music():
	music_player.stop()

func play_sfx(path: String):
	var stream = load(path)
	if not stream:
		push_warning("SFX file not found: %s" % path)
		return

	for p in sfx_players:
		if not p.playing:
			p.stream = stream
			p.play()
			return
	
	sfx_players[0].stream = stream
	sfx_players[0].play()

func set_master_volume(value: float):
	master_volume = clamp(value, 0.0, 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(master_volume))

func set_music_volume(value: float):
	music_volume = clamp(value, 0.0, 1.0)
	AudioServer.set_bus_volume_db( AudioServer.get_bus_index("Music"), linear_to_db(music_volume) )

func set_sfx_volume(value: float):
	sfx_volume = clamp(value, 0.0, 1.0)
	AudioServer.set_bus_volume_db( AudioServer.get_bus_index("SFX"), linear_to_db(sfx_volume) )

func set_environment_volume(value: float):
	environment_volume = clamp(value, 0.0, 1.0)
	AudioServer.set_bus_volume_db( AudioServer.get_bus_index("Environment"), linear_to_db(environment_volume) )

func apply_from_settings(settings: Node):
	set_master_volume(settings.master_volume / 100.0)
	set_music_volume(settings.music_volume / 100.0)
	set_sfx_volume(settings.sfx_volume / 100.0)
	set_environment_volume(settings.environment_volume / 100.0)
