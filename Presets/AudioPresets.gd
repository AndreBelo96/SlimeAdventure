# AudioPresets.gd
extends Node

const DUNGEON_AMBIENT: Array[Dictionary] = [
	{
		"sounds": [
			"res://Assets/Audio/Sound/drip.wav"
		],
		"min_time": 2.0,
		"max_time": 5.0
	},
	{
		"sounds": [
			"res://Assets/Audio/Sound/echo/Eco.wav",
			"res://Assets/Audio/Sound/echo/sound.wav"
		],
		"min_time": 10.0,
		"max_time": 25.0
	}
]

const MAIN_MENU_MUSIC: String = "res://Assets/Audio/Music/Levels/menu_song.wav"
const DUNGEON_MUSIC: String = "res://Assets/Audio/Music/Levels/dungeon_song.wav"

# --- SFX ripetuti in più file ---
const SMASH_STONE: String = "res://Assets/Audio/Sound/SmashStone.wav"
const ACTIVATE_SPINE: String = "res://Assets/Audio/Sound/Spike/ActivateSpine.wav"
const DEACTIVATE_SPINE: String = "res://Assets/Audio/Sound/Spike/DeactivateSpine.wav"
const DEATH: String = "res://Assets/Audio/Sound/Death.wav"
