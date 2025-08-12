extends Control

@onready var location_container: GridContainer = $CanvasLayer/Menu/CenterContainer/LocationContainer
var LocationButtonScene = preload("res://Scenes/UI/Buttons/LocationButton.tscn")

func _ready() -> void:
	_refresh_location_buttons()

# --- UI CREATION --- #
func _refresh_location_buttons() -> void:
	_clear_location_buttons()
	for location_name in GameManager.get_all_locations():
		var button := _create_location_button(location_name)
		location_container.add_child(button)

func _clear_location_buttons() -> void:
	for child in location_container.get_children():
		child.queue_free()

func _create_location_button(location_name: String) -> Button:
	var btn = LocationButtonScene.instantiate()
	
	var location_type = GameManager.get_location_type(location_name)
	var locked = GameManager.is_location_locked(location_name)
	var theme = ThemeManager.get_theme_for_location_type(location_type)
	
	btn.setup(location_name, locked, theme)
	btn.pressed.connect(_on_location_selected.bind(location_name))
	return btn

# --- EVENTS --- #
func _on_location_selected(location_name: String) -> void:
	GameManager.location_selected = GameManager.Location[location_name]
	get_tree().change_scene_to_file("res://Scenes/UI/LevelMenu.tscn")

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/MainMenu.tscn")
