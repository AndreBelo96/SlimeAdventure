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


func _input(event):
	if event is InputEventKey and event.pressed:
		GameManager.next_level()
