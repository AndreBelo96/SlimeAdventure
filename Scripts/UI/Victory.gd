extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var sprite = $CanvasLayer/Victory
	
	var liv = str(GameManager.current_level)
	var best_steps := "-"
	var best_time := "-"
	
	if GameManager.save_data["levels"].has(liv):
		var data = GameManager.save_data["levels"][liv]
		best_steps = str(data.get("steps", "-"))
		best_time = str(data.get("time", "-")).substr(0, 4)
	else:
		best_steps = str(GameManager.current_steps)
		best_time = str(GameManager.current_time).substr(0, 4)
	
	$CanvasLayer/Actual.text = "Steps: " + str(GameManager.current_steps) + "\nTime: " + str(GameManager.current_time).substr(0, 4)
	$CanvasLayer/Best.text = "Steps: " + best_steps + "\nTime: " + best_time
	
	# Se non è un record, usa la texture atlas
	if not GameManager.isRecord:
		var atlas := AtlasTexture.new()
		atlas.atlas = preload("res://Assets/Sprites/Player/SlimeSet.png")
		atlas.region = Rect2(Vector2(0, 0), Vector2(32, 32))
		sprite.texture = atlas
		$CanvasLayer/Record.text = "Nice!!"
	else:
		print("RECORD")
		$CanvasLayer/Record.text = "New record!!"
		sprite.texture = preload("res://Assets/Sprites/Player/Sunglasses.png")
		GameManager.isRecord = false
	


func _input(event):
	if event is InputEventKey and event.pressed:
		GameManager.next_level()
