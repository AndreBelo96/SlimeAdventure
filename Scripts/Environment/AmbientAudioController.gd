extends Node

@export var ambient_events: Array[Dictionary] = []

func _ready():
	for event in ambient_events:
		start_event(event)

func start_event(event: Dictionary):
	run_event_loop(event)

func run_event_loop(event: Dictionary):
	while true:
		var delay = randf_range(event.min_time, event.max_time)
		await get_tree().create_timer(delay).timeout
		play_event(event)

func play_event(event: Dictionary):
	var sound = event.sounds.pick_random()
	SoundManager.play_environment(sound)
