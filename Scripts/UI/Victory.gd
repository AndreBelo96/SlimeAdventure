extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var sprite = $CanvasLayer/Victory
	
	# Dati dell’ultima run, salvati in GameManager.end_level()
	var last = GameManager.last_attempt
	var completed_level: int = int(last["level"])
	var run_steps: int = int(last["steps"])
	var run_time: float = float(last["time"])
	var is_record: bool = bool(last.get("is_record", false))

	# Mostra i risultati della run appena conclusa
	$CanvasLayer/Actual.text = "Steps: %d\nTime: %.2f" % [run_steps, run_time]
	
	var best_steps := "-"
	var best_time := "-"
	
	var level_data := SaveManager.get_level_data(completed_level)
	if level_data.size() > 0:
		best_steps = str(level_data.get("steps", "-"))
		best_time = "%.2f" % float(level_data.get("time", 0.0))
	else:
		# prima volta: non c'erano dati, mostra i valori della run
		best_steps = str(run_steps)
		best_time = "%.2f" % run_time

	$CanvasLayer/Best.text = "Steps: %s\nTime: %s" % [best_steps, best_time]
	
	if is_record:
		$CanvasLayer/Record.text = "New record!!"
		sprite.texture = preload("res://Assets/Sprites/Player/Sunglasses.png")
	else:
		$CanvasLayer/Record.text = "Nice!!"
		var atlas := AtlasTexture.new()
		atlas.atlas = preload("res://Assets/Sprites/Player/SlimeSet.png")
		atlas.region = Rect2(Vector2(0, 0), Vector2(32, 32))
		sprite.texture = atlas

	# (facoltativo) azzera il flag globale se lo usi altrove
	GameManager.isRecord = false


func _on_back_main_menu_pressed() -> void:
	SoundManager.play_sfx("res://Assets/Audio/DefaultBtnClick.wav")
	get_tree().change_scene_to_file("res://Scenes/UI/MainMenu.tscn")

func _on_back_level_selection_pressed() -> void:
	SoundManager.play_sfx("res://Assets/Audio/DefaultBtnClick.wav")
	get_tree().change_scene_to_file("res://Scenes/UI/LocationSelection.tscn")

func _on_restart_pressed() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	SoundManager.play_sfx("res://Assets/Audio/DefaultBtnClick.wav")
	GameManager.next_level()
