extends Control

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_continua_pressed() -> void:
	get_tree().paused = false
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _on_riprova_pressed() -> void:
	get_tree().paused = false
	GameManager.restart_level()
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _on_torna_menù_pressed() -> void:
	get_tree().paused = false
	GameManager.return_to_menu()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
