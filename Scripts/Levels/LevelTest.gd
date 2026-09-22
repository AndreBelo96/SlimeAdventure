extends "res://Scripts/Levels/LevelManager.gd"

## Livello di sviluppo: si lancia con F6, non è raggiungibile dai menu
## e non tocca mai il salvataggio.

@export var simulated_level := 14   # decide location, tileset, sfondo, effetti
@export var unlock_pickaxe := true
@export var test_victory_mode: VictoryMode = VictoryMode.TILES

func _enter_tree() -> void:
	# _enter_tree del padre gira PRIMA dei _ready delle tile figlie
	LevelStateManager.current_level = simulated_level
	LevelStateManager.has_pickaxe = unlock_pickaxe

func _ready():
	super._ready()
	player.reset_end_level_variables()
	victory_mode = test_victory_mode
	time_running = true
	GameLogger.info("[TEST] simulo il livello %d" % simulated_level)

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_R:
		_restart()
		return
	super._unhandled_input(event)

# Override: niente end_level(), niente Defeat/Victory, niente save
func _on_player_died():
	await get_tree().create_timer(1.0, true).timeout
	_restart()

func _on_player_won():
	await player.on_finish_level()
	GameLogger.info("[TEST] vittoria in %d passi, %ds" % [steps, level_time])
	_restart()

func _restart() -> void:
	for type in LevelStateManager.death_counts:
		LevelStateManager.death_counts[type] = 0
	get_tree().paused = false
	get_tree().reload_current_scene()
