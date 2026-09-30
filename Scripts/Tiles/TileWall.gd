extends "res://Scripts/Tiles/TileBase.gd"

var is_broken := false

func _ready():
	super._ready()
	weight = BLOCKED_WEIGHT

func _atlas_id() -> String:
	return "wall"

func can_enter() -> bool:
	return LevelStateManager.has_pickaxe

func on_player_enter():
	if !is_broken:
		animated_tile.play("EXPLOSION")
		SoundManager.play_sfx(AudioPresets.SMASH_STONE, 0.0, 0.08)
		weight = 1
		is_broken = true
