extends Node

var started := false
@export var ambient_events: Array[Dictionary] = []

func setup(events: Array[Dictionary]):
	if started:
		return
	
	started = true
	ambient_events = events
	start()

func start():
	for event in ambient_events:
		start_event(event)

func start_event(event: Dictionary) -> void:
	run_event_loop(event)

func run_event_loop(event: Dictionary):
	while true:
		var delay = randf_range(event["min_time"], event["max_time"])
		await get_tree().create_timer(delay).timeout
		play_event(event)

func play_event(event: Dictionary):
	var sound = event["sounds"].pick_random()
	SoundManager.play_environment(sound)
