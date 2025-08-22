# Scripts/SoundManager.gd
extends Node

const AUDIO_SETTINGS_PATH := "user://audio_settings.save"

var music_volume: float = 1.0
var sfx_volume: float = 1.0

var music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []

func _ready():
	load_settings()

	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)

	for i in range(8):
		var p = AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		sfx_players.append(p)

	apply_volumes()

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

func set_music_volume(value: float):
	music_volume = clamp(value, 0.0, 1.0)
	apply_volumes()
	save_settings()

func set_sfx_volume(value: float):
	sfx_volume = clamp(value, 0.0, 1.0)
	apply_volumes()
	save_settings()

func apply_volumes():
	AudioServer.set_bus_volume_db( AudioServer.get_bus_index("Music"), linear_to_db(music_volume) )
	AudioServer.set_bus_volume_db( AudioServer.get_bus_index("SFX"), linear_to_db(sfx_volume) )

func save_settings():
	var file = FileAccess.open(AUDIO_SETTINGS_PATH, FileAccess.WRITE)
	if file:
		var data = {
			"music_volume": music_volume,
			"sfx_volume": sfx_volume
		}
		file.store_string(JSON.stringify(data))
		file.close()

func load_settings():
	if not FileAccess.file_exists(AUDIO_SETTINGS_PATH):
		return
	
	var file = FileAccess.open(AUDIO_SETTINGS_PATH, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	var result = JSON.parse_string(content)
	if result is Dictionary:
		music_volume = float(result.get("music_volume", 1.0))
		sfx_volume = float(result.get("sfx_volume", 1.0))
